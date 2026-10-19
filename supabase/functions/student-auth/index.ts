import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://aqsa-field-training.netlify.app',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json; charset=utf-8',
};

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: corsHeaders });
}
function digits(v: unknown): string { return String(v ?? '').replace(/\D/g, ''); }
function normalizeArabic(v: unknown): string {
  return String(v ?? '').trim().toLowerCase().normalize('NFD')
    .replace(/[\u064B-\u065F\u0670\u0640]/g, '').replace(/[أإآ]/g, 'ا')
    .replace(/ى/g, 'ي').replace(/ة/g, 'ه').replace(/\s+/g, ' ');
}
function syntheticEmail(n: string): string { return 'student-' + n + '@students.aqsa.invalid'; }
function genderFromNumber(n: string): 'male' | 'female' | null {
  if (n.startsWith('122')) return 'male'; if (n.startsWith('222')) return 'female'; return null;
}
function regionMatches(area: string, region: string): boolean {
  const a = normalizeArabic(area).replace(/ال/g, ''), r = normalizeArabic(region).replace(/ال/g, '');
  if (['كل المناطق','كل غزة','الفرعين','الفرعان','جميع المناطق','الكل'].some(x => r.includes(normalizeArabic(x).replace(/ال/g, '')))) return true;
  if (a.includes('غزة') || a.includes('شمال')) return r.includes('غزة') || r.includes('شمال');
  if (a.includes('وسطى')) return r.includes('وسطى');
  if (a.includes('خانيونس') || a.includes('رفح')) return r.includes('جنوب') || r.includes('خانيونس') || r.includes('رفح');
  return a === r || r.includes(a);
}
function categoryMatches(gender: 'male' | 'female', category: string): boolean {
  const c = normalizeArabic(category).replace(/ال/g, '');
  if (c.includes('جميع') || c.includes('كل') || c.includes('طلاب وطالبات') || c.includes('طالبات وطلاب')) return true;
  return gender === 'male' ? (c.includes('طلاب') || c.includes('ذكور')) : (c.includes('طالبات') || c.includes('اناث'));
}
function specialtyMatches(a: string, b: string): boolean {
  const x = normalizeArabic(a).replace(/ال/g, '').replace(/[\s\-_]/g, '');
  const y = normalizeArabic(b).replace(/ال/g, '').replace(/[\s\-_]/g, '');
  return !!x && !!y && x === y;
}
function requiredEnv(key: string): string { const v = Deno.env.get(key); if (!v) throw new Error('Missing server secret: ' + key); return v; }
function tempPassword(): string {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@$%';
  const random = new Uint8Array(18); crypto.getRandomValues(random);
  return Array.from(random, b => alphabet[b % alphabet.length]).join('') + 'aA7!';
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { status: 200, headers: corsHeaders });
  if (req.method !== 'POST') return json({ error: 'طريقة الطلب غير مدعومة.' }, 405);
  let body: Record<string, any>;
  try { body = await req.json(); } catch { return json({ error: 'تعذر قراءة بيانات الطلب.' }, 400); }
  if (!body || typeof body !== 'object' || Array.isArray(body)) return json({ error: 'بيانات الطلب غير صحيحة.' }, 400);
  try {
    const url = requiredEnv('SUPABASE_URL');
    const serviceKey = requiredEnv('SUPABASE_SERVICE_ROLE_KEY');
    const anonKey = requiredEnv('SUPABASE_ANON_KEY');
    const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
    const client = createClient(url, anonKey, { auth: { persistSession: false, autoRefreshToken: false } });
    const action = String(body.action || '');

    if (action === 'signup') {
      const fullName = String(body.full_name || '').trim();
      const n = digits(body.university_number);
      const phone = String(body.phone || '').trim();
      const area = String(body.student_area || '').trim();
      const specialtyId = Number(body.specialty_id);
      const supervisorId = Number(body.supervisor_id);
      const password = String(body.password || '');
      const gender = genderFromNumber(n);
      if (!fullName || !n || !phone || !area || !Number.isSafeInteger(specialtyId) || specialtyId < 1 || !Number.isSafeInteger(supervisorId) || supervisorId < 1 || password.length < 8) return json({ error: 'أكمل الحقول المطلوبة واختر تخصصًا ومشرفًا، واجعل كلمة المرور 8 أحرف على الأقل.' }, 400);
      if (!gender) return json({ error: 'الرقم الجامعي غير مطابق: 122 للطلاب و222 للطالبات.' }, 400);
      const { data: roster, error: rosterError } = await admin.from('eligible_student_roster').select('university_number,full_name,gender,specialty_id,is_active').eq('university_number', n).maybeSingle();
      if (rosterError) return json({ error: 'قائمة الطلاب المعتمدة غير جاهزة. على القسم مراجعة إعداد قاعدة البيانات وقائمة التسجيل أولًا.' }, 503);
      if (!roster || roster.is_active === false) return json({ error: 'الرقم الجامعي غير موجود في قائمة التسجيل المعتمدة. راجع قسم التدريب الميداني.' }, 403);
      if (normalizeArabic(roster.full_name).replace(/ال/g, '').replace(/\s/g, '') !== normalizeArabic(fullName).replace(/ال/g, '').replace(/\s/g, '')) return json({ error: 'الاسم لا يطابق كشف القسم المعتمد.' }, 403);
      if (roster.gender !== gender) return json({ error: 'فئة الطالب لا تطابق بيانات القسم.' }, 403);
      if (roster.specialty_id != null && Number(roster.specialty_id) !== specialtyId) return json({ error: 'التخصص لا يطابق تخصص الطالب في كشف القسم.' }, 403);
      const { data: specialty, error: spError } = await admin.from('specialties').select('id,name').eq('id', specialtyId).eq('is_active', true).maybeSingle();
      if (spError || !specialty) return json({ error: 'التخصص المختار غير متاح. حدّث الصفحة واختر تخصصًا معتمدًا.' }, 400);
      const { data: supervisor, error: supError } = await admin.from('public_supervisors').select('id,name,region,category,specialty,phone,is_active').eq('id', supervisorId).maybeSingle();
      if (supError || !supervisor || supervisor.is_active === false) return json({ error: 'المشرف المختار غير موجود أو غير نشط.' }, 400);
      if (!regionMatches(area, supervisor.region) || !categoryMatches(gender, supervisor.category) || !specialtyMatches(specialty.name, supervisor.specialty)) return json({ error: 'المشرف لا يطابق المنطقة أو التخصص أو فئة الطالب.' }, 400);
      const { data: existing, error: exErr } = await admin.from('student_profiles').select('user_id').eq('university_number', n).maybeSingle();
      if (exErr) return json({ error: 'تعذر التحقق من الرقم الجامعي.' }, 500);
      if (existing) return json({ error: 'يوجد حساب مسجل بهذا الرقم الجامعي. استخدم الدخول أو راجع القسم.' }, 409);
      const email = syntheticEmail(n);
      const { data: created, error: createError } = await admin.auth.admin.createUser({ email, password, email_confirm: true, user_metadata: { full_name: fullName, university_number: n, gender, specialty_id: String(specialtyId), phone } });
      if (createError || !created.user) return json({ error: createError?.message || 'تعذر إنشاء الحساب.' }, 400);
      const { error: profileError } = await admin.from('student_profiles').upsert({ user_id: created.user.id, university_number: n, full_name: fullName, gender, specialty_id: specialtyId, phone, email, completed_hours: null, eligibility_status: 'pending', student_area: area, supervisor_name: supervisor.name, supervisor_phone: supervisor.phone || null }, { onConflict: 'user_id' });
      if (profileError) { await admin.auth.admin.deleteUser(created.user.id); return json({ error: 'تعذر حفظ ملف الطالب؛ أُلغي الحساب الجديد. راجع مخطط قاعدة البيانات.' }, 500); }
      const { error: roleError } = await admin.from('user_roles').upsert({ user_id: created.user.id, role: 'student', is_active: true }, { onConflict: 'user_id' });
      if (roleError) { await admin.auth.admin.deleteUser(created.user.id); return json({ error: 'تعذر إنشاء صلاحية الطالب؛ أُلغي الحساب الجديد.' }, 500); }
      const { data: login, error: loginError } = await client.auth.signInWithPassword({ email, password });
      if (loginError || !login.session) { await admin.auth.admin.deleteUser(created.user.id); return json({ error: 'تعذر إكمال الدخول بعد إنشاء الحساب؛ أُلغي الحساب الجديد.' }, 500); }
      return json({ ok: true, session: login.session, user: login.user });
    }

    if (action === 'login') {
      const identifier = String(body.identifier || '').trim(); const password = String(body.password || '');
      if (!identifier || !password) return json({ error: 'أدخل الرقم الجامعي أو البريد الوظيفي وكلمة المرور.' }, 400);
      let email = identifier;
      if (!identifier.includes('@')) {
        const n = digits(identifier); if (!n) return json({ error: 'أدخل رقمًا جامعيًا صحيحًا.' }, 400);
        const { data: profile, error } = await admin.from('student_profiles').select('email').eq('university_number', n).maybeSingle();
        if (error || !profile?.email) return json({ error: 'لم نعثر على حساب بهذا الرقم الجامعي. راجع القسم إذا كنت مسجلًا.' }, 401);
        email = String(profile.email);
      }
      const { data: login, error } = await client.auth.signInWithPassword({ email, password });
      if (error || !login.session) return json({ error: 'تعذر تسجيل الدخول. تحقق من الرقم الجامعي/البريد الوظيفي وكلمة المرور.' }, 401);
      return json({ ok: true, session: login.session, user: login.user });
    }

    if (action === 'request_reset') {
      const n = digits(body.university_number); const phone = String(body.phone || '').trim();
      if (!n || !phone) return json({ error: 'أدخل الرقم الجامعي ورقم الجوال المسجل.' }, 400);
      const generic = 'إذا تطابقت بياناتك، فسيصل الطلب للقسم لمراجعته. إذا لم يصلك رد، راجع قسم التدريب الميداني مباشرة.';
      const { data: profile, error } = await admin.from('student_profiles').select('university_number,phone').eq('university_number', n).maybeSingle();
      if (error || !profile || digits(profile.phone) !== digits(phone)) return json({ ok: true, message: generic });
      const { data: pending, error: pErr } = await admin.from('student_password_reset_requests').select('id').eq('university_number', n).eq('status', 'pending').limit(1);
      if (!pErr && pending?.length) return json({ ok: true, message: generic });
      const { error: insertError } = await admin.from('student_password_reset_requests').insert({ university_number: n, phone, status: 'pending' });
      if (insertError) return json({ error: 'خدمة الاسترجاع غير جاهزة؛ راجع القسم مباشرة.' }, 503);
      return json({ ok: true, message: generic });
    }

    const authHeader = req.headers.get('Authorization') || ''; const token = authHeader.replace(/^Bearer\s+/i, '');
    if (!token) return json({ error: 'يلزم تسجيل الدخول.' }, 401);
    const { data: authData, error: authError } = await client.auth.getUser(token);
    if (authError || !authData.user) return json({ error: 'جلسة الدخول غير صالحة.' }, 401);
    const currentUser = authData.user;

    if (action === 'change_password') {
      const newPassword = String(body.new_password || '');
      if (newPassword.length < 10) return json({ error: 'كلمة المرور الجديدة يجب أن تتكون من 10 أحرف على الأقل.' }, 400);
      if (currentUser.user_metadata?.must_change_password !== true) return json({ error: 'لا يوجد طلب لتغيير كلمة مرور مؤقتة على هذا الحساب.' }, 403);
      const metadata = { ...(currentUser.user_metadata || {}), must_change_password: false };

      const { error } = await admin.auth.admin.updateUserById(currentUser.id, { password: newPassword, user_metadata: metadata });
      if (error) return json({ error: 'تعذر تغيير كلمة المرور.' }, 500);
      return json({ ok: true, message: 'تم تغيير كلمة المرور.' });
    }

    const { data: role, error: roleError } = await admin.from('user_roles').select('role,is_active').eq('user_id', currentUser.id).maybeSingle();
    if (roleError || !role || role.is_active === false || !['admin', 'department_head'].includes(role.role)) return json({ error: 'هذه العملية متاحة لرئيس القسم أو مدير النظام فقط.' }, 403);

    if (action === 'list_reset_requests') {
      const { data: requests, error } = await admin.from('student_password_reset_requests').select('id,university_number,phone,status,requested_at').eq('status', 'pending').order('requested_at', { ascending: true }).limit(100);
      if (error) return json({ error: 'تعذر تحميل طلبات الاسترجاع.' }, 500);
      const numbers = (requests || []).map(x => x.university_number);
      const { data: profiles } = numbers.length ? await admin.from('student_profiles').select('university_number,full_name').in('university_number', numbers) : { data: [] as any[] };
      const names = new Map((profiles || []).map(x => [x.university_number, x.full_name]));
      return json({ ok: true, requests: (requests || []).map(x => ({ ...x, full_name: names.get(x.university_number) || '' })) });
    }

    if (action === 'admin_reset_password') {
      const id = Number(body.request_id); if (!Number.isSafeInteger(id) || id < 1) return json({ error: 'رقم الطلب غير صحيح.' }, 400);
      const { data: request, error: reqError } = await admin.from('student_password_reset_requests').select('id,university_number,status').eq('id', id).eq('status', 'pending').maybeSingle();
      if (reqError || !request) return json({ error: 'الطلب غير موجود أو تمت معالجته.' }, 404);
      const { data: profile, error: profileError } = await admin.from('student_profiles').select('user_id').eq('university_number', request.university_number).maybeSingle();
      if (profileError || !profile) return json({ error: 'ملف الطالب غير موجود.' }, 404);
      const { data: target, error: targetError } = await admin.auth.admin.getUserById(profile.user_id);
      if (targetError || !target.user) return json({ error: 'حساب الطالب غير موجود.' }, 404);
      const temporary = tempPassword();
      const metadata = { ...(target.user.user_metadata || {}), must_change_password: true };

      const { error: updateError } = await admin.auth.admin.updateUserById(profile.user_id, { password: temporary, user_metadata: metadata });
      if (updateError) return json({ error: 'تعذر إصدار كلمة المرور المؤقتة.' }, 500);
      const { error: doneError } = await admin.from('student_password_reset_requests').update({ status: 'approved', resolved_at: new Date().toISOString(), resolved_by: currentUser.id }).eq('id', id);
      if (doneError) return json({ error: 'تغيّرت كلمة المرور، لكن لم تتحدث حالة الطلب. راجع سجل القسم.' }, 500);
      return json({ ok: true, university_number: request.university_number, temporary_password: temporary });
    }
    return json({ error: 'الإجراء المطلوب غير معروف.' }, 400);
  } catch (e) { return json({ error: e instanceof Error ? e.message : 'حدث خطأ غير متوقع.' }, 500); }
});
