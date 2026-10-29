import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

function reply(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}

function normalizeArabicName(value: unknown) {
  return String(value ?? "").toLowerCase().normalize("NFD")
    .replace(/[\u064B-\u065F\u0670\u0640]/g, "")
    .replace(/[أإآٱ]/g, "ا").replace(/ى/g, "ي").replace(/ة/g, "ه")
    .replace(/[\s\-_]/g, "");
}

async function authorizeDepartmentHead(admin: any, req: Request): Promise<
  { ok: true; userId: string } | { ok: false; status: number; message: string }
> {
  const bearer = String(req.headers.get("authorization") || "").replace(/^Bearer\s+/i, "").trim();
  if (!bearer) return { ok: false, status: 401, message: "سجّل الدخول بحساب رئيس القسم أولًا." };
  const { data: authResult, error: authError } = await admin.auth.getUser(bearer);
  if (authError || !authResult?.user) {
    return { ok: false, status: 401, message: "انتهت جلسة الدخول؛ سجّل الدخول مجددًا." };
  }
  const { data: roleRow, error: roleError } = await admin.from("user_roles")
    .select("role,is_active")
    .eq("user_id", authResult.user.id)
    .eq("role", "department_head")
    .eq("is_active", true)
    .maybeSingle();
  if (roleError) return { ok: false, status: 500, message: "تعذر التحقق من صلاحية رئيس القسم." };
  if (!roleRow) return { ok: false, status: 403, message: "هذه الوظيفة لرئيس القسم فقط." };
  return { ok: true, userId: authResult.user.id };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return reply({ error: "طريقة الطلب غير مدعومة." }, 405);

  const url = Deno.env.get("SUPABASE_URL");
  const publicKey = Deno.env.get("SUPABASE_ANON_KEY") || Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !publicKey || !serviceKey) {
    console.error("supervisor-auth configuration missing", { url: !!url, publicKey: !!publicKey, serviceKey: !!serviceKey });
    return reply({ error: "إعدادات خدمة حسابات المشرفين غير مكتملة." }, 500);
  }

  const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
  const publicAuth = createClient(url, publicKey, { auth: { persistSession: false, autoRefreshToken: false } });

  try {
    const body = await req.json();
    const action = String(body?.action || "");

    if (action === "set_national_id") {
      const head = await authorizeDepartmentHead(admin, req);
      if (!head.ok) return reply({ error: head.message }, head.status);
      const supervisorId = Number(body?.supervisor_id);
      const nationalId = String(body?.national_id || "").replace(/\D/g, "");
      if (!Number.isInteger(supervisorId) || supervisorId <= 0) return reply({ error: "حدد سجل المشرف الصحيح." }, 400);
      if (!/^\d{7,12}$/.test(nationalId)) return reply({ error: "أدخل رقم هوية صحيحًا من 7 إلى 12 رقمًا." }, 400);
      const { error: identityError } = await admin.rpc("set_supervisor_login_identity", {
        p_supervisor_id: supervisorId, p_national_id: nationalId,
      });
      if (identityError) {
        const message = String(identityError.message || "");
        const safeMessage = message.includes("مسجل لمشرف آخر")
          ? "رقم الهوية مسجل لمشرف آخر."
          : message.includes("لديه حساب مرتبط")
            ? "هذا المشرف لديه حساب مرتبط بالفعل؛ لا يمكن تغيير هويته من هذه الشاشة."
            : message.includes("غير موجود أو غير نشط")
              ? "سجل المشرف غير موجود أو غير نشط."
              : message.includes("من 7 إلى 12")
                ? "أدخل رقم هوية صحيحًا من 7 إلى 12 رقمًا."
                : "تعذر حفظ الهوية. تحقق من البيانات أو راجع مسؤول النظام.";
        return reply({ error: safeMessage }, 400);
      }
      return reply({ saved: true, message: "تم حفظ الهوية في السجل الخاص. لم يُنشأ حساب دخول بعد." });
    }

    if (action === "reset_password") {
      const head = await authorizeDepartmentHead(admin, req);
      if (!head.ok) return reply({ error: head.message }, head.status);
      const supervisorId = Number(body?.supervisor_id);
      if (!Number.isInteger(supervisorId) || supervisorId <= 0) {
        return reply({ error: "حدد سجل المشرف الصحيح." }, 400);
      }
      const { data: records, error: lookupError } = await admin.rpc("list_supervisor_account_status");
      if (lookupError || !Array.isArray(records)) {
        console.error("supervisor reset lookup failed", lookupError?.message || "invalid result");
        return reply({ error: "تعذر التحقق من حساب المشرف." }, 500);
      }
      const supervisor = records.find((item: any) => Number(item.supervisor_id) === supervisorId);
      if (!supervisor || supervisor.supervisor_active !== true || !supervisor.account_user_id) {
        return reply({ error: "لا يوجد حساب مرتبط ونشط لهذا المشرف." }, 404);
      }
      const { data: linkedUser, error: userError } = await admin.auth.admin.getUserById(String(supervisor.account_user_id));
      if (userError || !linkedUser?.user) {
        return reply({ error: "تعذر العثور على حساب الدخول المرتبط." }, 404);
      }
      const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%";
      const random = new Uint8Array(24);
      crypto.getRandomValues(random);
      let temporaryPassword = "";
      for (const byte of random) temporaryPassword += alphabet[byte % alphabet.length];
      const { data: updated, error: updateError } = await admin.auth.admin.updateUserById(String(supervisor.account_user_id), {
        password: temporaryPassword,
        user_metadata: { ...(linkedUser.user.user_metadata || {}), must_change_password: true },
      });
      if (updateError || !updated?.user) {
        console.error("supervisor temporary password reset failed", updateError?.message || "missing user");
        return reply({ error: "تعذر تعيين كلمة المرور المؤقتة." }, 500);
      }
      return reply({
        reset: true,
        supervisor_name: supervisor.supervisor_name,
        temporary_password: temporaryPassword,
        message: "تم إصدار كلمة مرور مؤقتة للحساب المرتبط.",
      });
    }

    if (action === "signup") {
      const fullName = String(body?.full_name || "").trim();
      const nationalId = String(body?.national_id || body?.identifier || "").replace(/\D/g, "");
      const password = String(body?.password || "");
      if (!fullName || !/^\d{7,12}$/.test(nationalId) || !password) {
        return reply({ error: "أدخل الاسم كما هو في سجل القسم، ورقم الهوية، وكلمة المرور." }, 400);
      }
      if (password.length < 10) return reply({ error: "كلمة المرور يجب ألا تقل عن 10 أحرف." }, 400);

      const { data: matches, error: lookupError } = await admin.rpc("lookup_supervisor_self_registration", {
        p_national_id: nationalId,
      });
      if (lookupError) {
        console.error("supervisor self-registration lookup failed", lookupError.message);
        return reply({ error: "تعذر التحقق من بيانات المشرف. راجع رئيس القسم." }, 500);
      }
      if (!Array.isArray(matches) || matches.length !== 1) {
        return reply({ error: "رقم الهوية غير مسجل ضمن سجلات المشرفين. اطلب من رئيس القسم تسجيل الهوية أولًا." }, 403);
      }
      const supervisor = matches[0];
      if (supervisor.supervisor_active !== true) return reply({ error: "سجل المشرف غير نشط؛ راجع رئيس القسم." }, 403);
      if (supervisor.supervisor_user_id) {
        return reply({ error: "هذا المشرف لديه حساب مرتبط بالفعل. استخدم تسجيل الدخول أو اطلب استرجاع كلمة المرور." }, 409);
      }
      if (normalizeArabicName(fullName) !== normalizeArabicName(supervisor.supervisor_name)) {
        return reply({ error: "الاسم لا يطابق سجل المشرف المعتمد لدى القسم." }, 403);
      }

      const email = `supervisor${supervisor.supervisor_id}@supervisors.aqsa.edu.ps`;
      const { data: created, error: createError } = await admin.auth.admin.createUser({
        email, password, email_confirm: true,
        user_metadata: {
          full_name: supervisor.supervisor_name,
          account_type: "supervisor",
          supervisor_id: String(supervisor.supervisor_id),
        },
      });
      if (createError || !created?.user) {
        console.error("supervisor account create failed", createError?.message || "missing created user");
        if (String(createError?.message || "").toLowerCase().includes("already")) {
          return reply({ error: "يوجد حساب دخول غير مربوط لهذا السجل. راجع رئيس القسم لإصلاح الربط." }, 409);
        }
        return reply({ error: "تعذر إنشاء حساب المشرف. راجع رئيس القسم أو مسؤول النظام." }, 500);
      }

      const userId = created.user.id;
      const { error: claimError } = await admin.rpc("claim_supervisor_self_registration", {
        p_supervisor_id: supervisor.supervisor_id,
        p_national_id: nationalId,
        p_full_name: fullName,
        p_user_id: userId,
      });
      if (claimError) {
        console.error("supervisor account claim failed", claimError.message);
        await admin.auth.admin.deleteUser(userId);
        const message = String(claimError.message || "");
        const safeMessage = message.includes("الاسم لا يطابق")
          ? "الاسم لا يطابق سجل المشرف المعتمد لدى القسم."
          : message.includes("الهوية غير مسجلة")
            ? "الهوية غير مسجلة لدى القسم؛ اطلب من رئيس القسم تسجيلها أولًا."
            : message.includes("حساب مرتبط بالفعل")
              ? "هذا المشرف لديه حساب مرتبط بالفعل."
              : "تعذر ربط الحساب بسجل المشرف. لم يكتمل التسجيل؛ راجع رئيس القسم.";
        return reply({ error: safeMessage }, 403);
      }

      const { data: signedIn, error: signInError } = await publicAuth.auth.signInWithPassword({ email, password });
      if (signInError || !signedIn?.session) {
        return reply({
          registered: true,
          message: "تم إنشاء حساب المشرف وربطه بنجاح. ارجع إلى تسجيل الدخول واستخدم رقم الهوية وكلمة المرور التي اخترتها.",
        });
      }
      return reply({ registered: true, session: signedIn.session });
    }

    if (action === "list_account_status") {
      const bearer = String(req.headers.get("authorization") || "").replace(/^Bearer\s+/i, "").trim();
      if (!bearer) return reply({ error: "سجّل الدخول بحساب رئيس القسم أولًا." }, 401);
      const { data: authResult, error: authErr } = await admin.auth.getUser(bearer);
      if (authErr || !authResult?.user) return reply({ error: "انتهت جلسة الدخول؛ سجّل الدخول مجددًا." }, 401);
      const { data: headRole, error: roleErr } = await admin.from("user_roles")
        .select("role,is_active")
        .eq("user_id", authResult.user.id)
        .eq("role", "department_head")
        .eq("is_active", true)
        .maybeSingle();
      if (roleErr) return reply({ error: "تعذر التحقق من صلاحية رئيس القسم." }, 500);
      if (!headRole) return reply({ error: "هذه الوظيفة لرئيس القسم فقط." }, 403);
      const { data: records, error: listErr } = await admin.rpc("list_supervisor_account_status");
      if (listErr || !Array.isArray(records)) {
        console.error("supervisor account status list failed", listErr?.message || "invalid result");
        return reply({ error: "تعذر تحميل حالة حسابات المشرفين." }, 500);
      }
      return reply({
        supervisors: records.map((item: any) => ({
          id: item.supervisor_id,
          name: item.supervisor_name,
          region: item.supervisor_region,
          category: item.supervisor_category,
          specialty: item.supervisor_specialty,
          active: item.supervisor_active === true,
          national_id_registered: item.has_national_id === true,
          account_linked: item.account_user_id !== null && item.account_user_id !== undefined,
        })),
      });
    }

    const identifier = String(body?.identifier || "").trim();
    const password = String(body?.password || "");
    if (!identifier || !password) return reply({ error: "أدخل رقم الهوية الوطنية وكلمة المرور." }, 400);

    let loginEmail = "";
    if (identifier.includes("@")) {
      // Retain compatibility with existing supervisors who use their work email.
      loginEmail = identifier.toLowerCase();
    } else {
      const nationalId = identifier.replace(/\D/g, "");
      if (!/^\d{7,12}$/.test(nationalId)) {
        return reply({ error: "أدخل رقم الهوية الوطنية الصحيح." }, 400);
      }

      const { data: matches, error: lookupError } = await admin.rpc("resolve_supervisor_login", {
        p_national_id: nationalId,
      });
      if (lookupError) {
        console.error("supervisor national ID lookup failed", lookupError.message);
        return reply({ error: "تعذر التحقق من هوية المشرف. راجع إعدادات ربط حسابات المشرفين." }, 500);
      }
      if (!Array.isArray(matches) || matches.length !== 1 || !matches[0]?.supervisor_user_id ||
          matches[0]?.supervisor_active !== true) {
        return reply({ error: "حساب المشرف غير مربوط أو غير مفعّل. راجع رئيس القسم." }, 403);
      }

      const { data: authUserResult, error: authUserError } = await admin.auth.admin.getUserById(
        matches[0].supervisor_user_id,
      );
      if (authUserError || !authUserResult?.user?.email) {
        console.error("supervisor linked auth account missing", authUserError?.message || "email unavailable");
        return reply({ error: "حساب المشرف غير مكتمل الربط. راجع رئيس القسم." }, 403);
      }
      loginEmail = authUserResult.user.email.toLowerCase();
    }

    const { data: signedIn, error: signInError } = await publicAuth.auth.signInWithPassword({
      email: loginEmail,
      password,
    });
    if (signInError || !signedIn.user || !signedIn.session) {
      return reply({ error: "بيانات الدخول غير صحيحة أو الحساب غير مفعّل." }, 401);
    }

    const { data: roleRow, error: roleError } = await admin
      .from("user_roles")
      .select("role,is_active")
      .eq("user_id", signedIn.user.id)
      .eq("role", "supervisor")
      .eq("is_active", true)
      .maybeSingle();

    if (roleError) {
      console.error("supervisor role verification failed", roleError.message);
      return reply({ error: "تعذر التحقق من صلاحية المشرف." }, 500);
    }
    if (!roleRow) return reply({ error: "هذا الحساب غير مخصص لمشرف تدريب نشط." }, 403);

    return reply({ session: signedIn.session });
  } catch (error) {
    console.error("supervisor-auth unexpected error", error);
    return reply({ error: "حدث خطأ غير متوقع أثناء تسجيل الدخول." }, 500);
  }
});
