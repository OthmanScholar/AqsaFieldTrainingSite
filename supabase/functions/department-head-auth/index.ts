// Supabase Edge Function: department-head-auth
// Authenticates a staff email and permits only department_head/admin roles.
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "طريقة الطلب غير مدعومة." }, 405);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const publicKey = Deno.env.get("SUPABASE_ANON_KEY") || Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
    if (!supabaseUrl || !publicKey) {
      console.error("Missing Supabase URL or public API key environment variable.");
      return json({ error: "إعدادات خدمة الحسابات غير مكتملة في Supabase." }, 500);
    }

    const body = await req.json();
    const identifier = String(body?.identifier || "").trim();
    const password = String(body?.password || "");
    if (!identifier || !password) return json({ error: "أدخل البريد الوظيفي وكلمة المرور." }, 400);
    if (!identifier.includes("@")) return json({ error: "دخول رئيس القسم يتطلب البريد الوظيفي، وليس الرقم الجامعي." }, 400);

    const authResponse = await fetch(`${supabaseUrl}/auth/v1/token?grant_type=password`, {
      method: "POST",
      headers: { "apikey": publicKey, "Content-Type": "application/json" },
      body: JSON.stringify({ email: identifier, password }),
    });
    const authData = await authResponse.json().catch(() => ({}));
    if (!authResponse.ok || !authData.access_token || !authData.user?.id) {
      return json({ error: "البريد الوظيفي أو كلمة المرور غير صحيحة، أو أن الحساب غير مفعّل." }, 401);
    }

    const roleUrl = new URL(`${supabaseUrl}/rest/v1/user_roles`);
    roleUrl.searchParams.set("user_id", `eq.${authData.user.id}`);
    roleUrl.searchParams.set("select", "role");
    const roleResponse = await fetch(roleUrl.toString(), {
      headers: {
        "apikey": publicKey,
        "Authorization": `Bearer ${authData.access_token}`,
        "Accept": "application/json",
      },
    });
    const roleRows = await roleResponse.json().catch(() => []);
    if (!roleResponse.ok) {
      console.error("Could not verify user role; status:", roleResponse.status);
      return json({ error: "تم التحقق من كلمة المرور، لكن تعذر التحقق من صلاحية رئيس القسم. راجع إعداد جدول user_roles وسياسات القراءة." }, 500);
    }

    const roles = Array.isArray(roleRows) ? roleRows.map((row: { role?: string }) => row.role) : [];
    if (!roles.includes("department_head") && !roles.includes("admin")) {
      return json({ error: "هذا الحساب غير مخصص لرئيس القسم. يجب أن يعيّن المدير العام صلاحية department_head للحساب." }, 403);
    }

    return json({
      session: {
        access_token: authData.access_token,
        refresh_token: authData.refresh_token,
        expires_in: authData.expires_in,
        expires_at: authData.expires_at,
        token_type: authData.token_type,
        user: authData.user,
      },
    });
  } catch (error) {
    console.error("department-head-auth error:", error);
    return json({ error: "حدث خطأ غير متوقع أثناء تسجيل الدخول. حاول مجددًا." }, 500);
  }
});
