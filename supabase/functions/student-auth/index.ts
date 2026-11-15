import "jsr:@supabase/functions-js/edge-runtime.d.ts";
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
function norm(v: unknown) {
  return String(v ?? "").toLowerCase().normalize("NFD")
    .replace(/[\u064B-\u065F\u0670\u0640]/g, "")
    .replace(/[أإآ]/g, "ا").replace(/ى/g, "ي").replace(/ة/g, "ه")
    .replace(/[\s\-_]/g, "");
}
function emailFor(number: string) {
  return `student${number}@students.aqsa.edu.ps`;
}
function regionMatches(area: string, region: string) {
  const a = norm(area), r = norm(region);
  if (!a || !r) return false;
  if (r.includes("مناطق") || r.includes("كلمناظق") || r.includes("جميعمناظق") ||
      r.includes("فرعين") || r.includes("فرعان") || r.includes("كلغزه") || r === "الكل") return true;
  if (a.includes("غزه") || a.includes("شمال")) return r.includes("غزه") || r.includes("شمال") || r.includes("شفاء");
  if (a.includes("وسطي")) return r.includes("وسطي") || r.includes("مغازي") || r.includes("ديربلح") || r.includes("نصيرات");
  if (a.includes("جنوب") || a.includes("خانيونس") || a.includes("رفح")) return r.includes("جنوب") || r.includes("خانيونس") || r.includes("رفح");
  return r.includes(a);
}
function categoryMatches(gender: string, category: string) {
  const c = norm(category);
  if (!c) return false;
  if (c.includes("جميع") || c.includes("كلفئات") || c.includes("طلابوطالبات") || c.includes("طالباتوطلب")) return true;
  return gender === "male"
    ? c === "طلاب" || c.includes("طلاب") || c.includes("ذكور")
    : c === "طالبات" || c.includes("طالبات") || c.includes("اناث");
}
function specialtyMatches(studentSpecialty: string, supervisorGroup: string) {
  const x = norm(studentSpecialty), y = norm(supervisorGroup);
  if (!x || !y) return false;
  if (x === y || x.replace(/ه/g, "") === y.replace(/ه/g, "")) return true;
  const groups: Record<string, string[]> = {
    [norm("العلوم التكنولوجية")]: ["أمن المعلومات", "التصميم الجرافيكي", "الوسائط المتعددة", "برمجة تطبيقات الهواتف الذكية", "تكنولوجيا المعلومات والاتصالات"],
    [norm("العلوم الإدارية")]: ["إدارة الأعمال", "السكرتاريا الدولية", "العلوم المالية والمصرفية"],
    [norm("العلوم الإعلامية")]: ["العلاقات العامة والإعلام", "الصحافة الإلكترونية"],
    [norm("العلوم التربوية")]: ["تربية الطفل"],
    [norm("علوم التربية البدنية")]: ["علوم التربية البدنية"],
    [norm("العلاج الوظيفي")]: ["العلاج الوظيفي"],
  };
  return (groups[y] || []).some(name => norm(name) === x);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return reply({ error: "طريقة الطلب غير مدعومة." }, 405);

  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") || Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !anonKey || !serviceKey) {
    console.error("student-auth configuration missing", { url: !!url, anonKey: !!anonKey, serviceKey: !!serviceKey });
    return reply({ error: "إعدادات خدمة حسابات الطلاب غير مكتملة في Supabase." }, 500);
  }

  const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
  const publicAuth = createClient(url, anonKey, { auth: { persistSession: false, autoRefreshToken: false } });

  try {
    const body = await req.json();
    const action = String(body?.action || "");
    if (action === "login") {
      const identifier = String(body?.identifier || "").trim();
      const password = String(body?.password || "");
      if (!identifier || !password) return reply({ error: "أدخل الرقم الجامعي وكلمة المرور." }, 400);
      const number = identifier.replace(/\s/g, "");
      if (!identifier.includes("@") && !/^(122|222|220)\d{2,}$/.test(number)) {
        return reply({ error: "تحقق من الرقم الجامعي؛ يجب أن يبدأ بـ122 للطلاب أو 222/220 للطالبات." }, 400);
      }
      const email = identifier.includes("@") ? identifier.toLowerCase() : emailFor(number);
      const { data: authData, error: authError } = await publicAuth.auth.signInWithPassword({ email, password });
      if (authError || !authData.session || !authData.user) {
        return reply({ error: "بيانات الدخول غير صحيحة أو الحساب غير مفعّل." }, 401);
      }
      const [{ data: roleRow, error: roleError }, { data: profile, error: profileError }] = await Promise.all([
        admin.from("user_roles").select("role,is_active").eq("user_id", authData.user.id).maybeSingle(),
        admin.from("student_profiles").select("user_id").eq("user_id", authData.user.id).maybeSingle(),
      ]);
      if (roleError || profileError || roleRow?.role !== "student" || roleRow?.is_active === false || !profile) {
        await publicAuth.auth.signOut();
        return reply({ error: "هذا الحساب غير مسجل كحساب طالب فعّال. راجع القسم." }, 403);
      }
      return reply({ session: authData.session });
    }


    if (action === "lookup") {
      const number = String(body?.university_number || "").trim().replace(/\s/g, "");
      if (!/^(122|222|220)\d{2,}$/.test(number)) return reply({ error: "تحقق من الرقم الجامعي؛ 122 للطلاب و222 أو 220 للطالبات." }, 400);
      const { data: roster, error: rosterError } = await admin.from("eligible_student_roster")
        .select("university_number,full_name,gender,specialty_id,is_active")
        .eq("university_number", number).maybeSingle();
      if (rosterError) {
        console.error("student-auth roster lookup error", rosterError);
        return reply({ error: "تعذر التحقق من الرقم الجامعي حاليًا. حاول مجددًا." }, 500);
      }
      if (!roster || !roster.is_active) return reply({ error: "الرقم الجامعي غير موجود في كشف الطلبة المؤهلين أو أن التسجيل غير مفعّل. راجع القسم." }, 403);
      const [{ data: existingProfile, error: existingError }, { data: specialty, error: specialtyError }] = await Promise.all([
        admin.from("student_profiles").select("user_id").eq("university_number", number).maybeSingle(),
        admin.from("specialties").select("id,name,is_active").eq("id", roster.specialty_id).maybeSingle()
      ]);
      if (existingError || specialtyError) {
        console.error("student-auth lookup detail error", { existingError, specialtyError });
        return reply({ error: "تعذر تحميل بيانات الطالب. حاول مجددًا." }, 500);
      }
      if (existingProfile) return reply({
        student: {
          university_number: roster.university_number,
          full_name: roster.full_name,
          gender: roster.gender,
          specialty_id: roster.specialty_id,
          specialty_name: specialty.name
        },
        account_exists: true,
        message: "هذا الرقم لديه حساب سابق. تم تحميل بيانات الطالبة؛ استخدمي تسجيل الدخول أو استعادة كلمة المرور بدل إنشاء حساب جديد."
      });
      if (!specialty || specialty.is_active === false) return reply({ error: "التخصص المرتبط بالرقم الجامعي غير مفعّل. راجع القسم." }, 403);
      return reply({ student: {
        university_number: roster.university_number,
        full_name: roster.full_name,
        gender: roster.gender,
        specialty_id: roster.specialty_id,
        specialty_name: specialty.name
      }});
    }

    if (action !== "signup") return reply({ error: "نوع العملية غير مدعوم." }, 400);

    const fullName = String(body?.full_name || "").trim();
    const number = String(body?.university_number || "").trim().replace(/\s/g, "");
    const phone = String(body?.phone || "").trim();
    const area = String(body?.student_area || "").trim();
    const specialtyId = Number(body?.specialty_id);
    const supervisorId = Number(body?.supervisor_id);
    const password = String(body?.password || "");

    if (!phone || !area || !Number.isInteger(specialtyId) || specialtyId <= 0 ||
        !Number.isInteger(supervisorId) || supervisorId <= 0 || !password) {
      return reply({ error: "أكمل جميع بيانات التسجيل واختر التخصص والمشرف." }, 400);
    }
    if (!/^(122|222|220)\d{2,}$/.test(number)) return reply({ error: "تحقق من الرقم الجامعي؛ 122 للطلاب و222 أو 220 للطالبات." }, 400);
    if (password.length < 8) return reply({ error: "كلمة المرور يجب ألا تقل عن 8 أحرف." }, 400);
    if (phone.length < 8 || phone.length > 20) return reply({ error: "تحقق من رقم الجوال." }, 400);

    const gender = number.startsWith("122") ? "male" : "female";
    const [{ data: roster, error: rosterError }, { data: specialty, error: specialtyError }, { data: supervisor, error: supervisorError }, { data: existingProfile, error: existingError }] = await Promise.all([
      admin.from("eligible_student_roster").select("university_number,full_name,gender,specialty_id,is_active").eq("university_number", number).maybeSingle(),
      admin.from("specialties").select("id,name,is_active").eq("id", specialtyId).maybeSingle(),
      admin.from("public_supervisors").select("id,name,region,category,specialty,phone,is_active").eq("id", supervisorId).maybeSingle(),
      admin.from("student_profiles").select("user_id").eq("university_number", number).maybeSingle(),
    ]);
    if (rosterError || specialtyError || supervisorError || existingError) {
      console.error("student-auth lookup error", { rosterError, specialtyError, supervisorError, existingError });
      return reply({ error: "تعذر التحقق من بيانات التسجيل. حاول مجددًا أو أبلغ القسم." }, 500);
    }
    if (!roster || !roster.is_active) return reply({ error: "الرقم الجامعي غير موجود في كشف الطلاب المؤهلين المعتمد." }, 403);
    if (existingProfile) return reply({ error: "يوجد حساب سابق لهذا الرقم الجامعي. لا تنشئ حسابًا جديدًا؛ سجّل الدخول أو استخدم استعادة كلمة المرور." }, 409);
    if (roster.gender !== gender) return reply({ error: "فئة الرقم الجامعي لا تطابق بيانات كشف القسم. راجع القسم." }, 403);
    if (roster.specialty_id != null && Number(roster.specialty_id) !== specialtyId) return reply({ error: "التخصص المختار لا يطابق التخصص المسجل في كشف القسم." }, 403);
    if (!specialty || specialty.is_active === false) return reply({ error: "التخصص المختار غير مفعّل." }, 400);
    if (!supervisor || supervisor.is_active === false ||
        !regionMatches(area, supervisor.region) ||
        !categoryMatches(gender, supervisor.category) ||
        !specialtyMatches(specialty.name || "", (Number(supervisor.id) === 13 ? "العلوم الإدارية" : supervisor.specialty || ""))) {
      return reply({ error: "المشرف المختار لا يطابق المنطقة أو التخصص أو فئة الطالب. اختر مشرفًا مطابقًا." }, 400);
    }

    const email = emailFor(number);
    const { data: created, error: createError } = await admin.auth.admin.createUser({
      email, password, email_confirm: true,
      user_metadata: {
        full_name: roster.full_name,
        university_number: number,
        gender,
        specialty_id: String(specialtyId),
        phone,
        student_area: area,
        account_type: "student",
      },
    });
    if (createError || !created.user) {
      if (createError?.message?.toLowerCase().includes("already")) {
        return reply({ error: "يوجد حساب سابق لهذا الرقم الجامعي. لا تنشئ حسابًا جديدًا؛ سجّل الدخول أو استخدم استعادة كلمة المرور." }, 409);
      }
      console.error("student-auth create user error", createError?.message);
      return reply({ error: "تعذر إنشاء حساب الطالب. راجع إعدادات خدمة الحسابات." }, 500);
    }

    const userId = created.user.id;
    const rollback = async () => {
      await admin.from("student_profiles").delete().eq("user_id", userId);
      await admin.from("user_roles").delete().eq("user_id", userId);
      await admin.auth.admin.deleteUser(userId);
    };
    const { error: profileError } = await admin.from("student_profiles").upsert({
      user_id: userId, university_number: number, full_name: roster.full_name, gender,
      specialty_id: specialtyId, phone, email, eligibility_status: "pending",
      student_area: area, supervisor_name: supervisor.name, supervisor_phone: supervisor.phone || null,
    }, { onConflict: "user_id" });
    if (profileError) {
      console.error("student-auth profile insert error", profileError.message);
      await rollback();
      if (profileError.code === "23505") {
        return reply({ error: "يوجد حساب سابق لهذا الرقم الجامعي. لا تنشئ حسابًا جديدًا؛ سجّل الدخول أو استخدم استعادة كلمة المرور." }, 409);
      }
      return reply({ error: "تم التحقق من بياناتك لكن تعذر حفظ ملف الطالب. لم يكتمل التسجيل؛ حاول مجددًا." }, 500);
    }
    const { error: roleError } = await admin.from("user_roles").upsert(
      { user_id: userId, role: "student", is_active: true }, { onConflict: "user_id" },
    );
    if (roleError) {
      console.error("student-auth role insert error", roleError.message);
      await rollback();
      return reply({ error: "تعذر تفعيل صلاحية الطالب، ولم يكتمل التسجيل. حاول مجددًا." }, 500);
    }

    const { data: signedIn, error: signInError } = await publicAuth.auth.signInWithPassword({ email, password });
    if (signInError || !signedIn.session) {
      console.error("student-auth sign-in after signup failed", signInError?.message);
      await rollback();
      return reply({ error: "تم إنشاء بيانات الحساب لكن تعذر بدء الجلسة؛ أعد المحاولة أو راجع القسم." }, 500);
    }
    return reply({ session: signedIn.session });
  } catch (error) {
    console.error("student-auth unexpected error", error);
    return reply({ error: "حدث خطأ غير متوقع أثناء خدمة حسابات الطلاب." }, 500);
  }
});
