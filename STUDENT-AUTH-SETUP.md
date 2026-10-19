# Student number/password login — staging only

This branch prepares a student-facing login without showing an email field and a server-side Supabase Edge Function. It is not ready for production until the live schema is reviewed, official rosters are imported, the function is deployed, and all end-to-end tests pass.

## Planned student flow
- Fields: full name, university number, mobile number, training area, specialty, matching supervisor, and password.
- Number prefixes are validated server-side: 122 = student, 222 = student.
- Registration requires a matching active entry in the department-controlled `public.eligible_student_roster` table.
- A reserved `.invalid` identifier is used internally for Supabase Auth and is not shown to students or used as a real mailbox.
- Staff retain their existing work-email login.
- Password recovery creates a request; authorized department staff verify identity offline before issuing a temporary password. The student then must change it.

## Before testing
1. Review `supabase/migrations/20261019_student_number_auth.sql` against the live tables/policies and apply it to a staging project first.
2. Import eligible students into `public.eligible_student_roster`; do not grant anonymous reads to that table.
3. Import the current official supervisor list to `public.public_supervisors`: name, area, specialty, category (طلاب / طالبات / الجميع), phone and active state.
4. Deploy `supabase/functions/student-auth`. Keep `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SUPABASE_SERVICE_ROLE_KEY` as server-side secrets; never put the service-role key in `index.html`.
5. Confirm email confirmation settings work with the internal identifier pattern; do not enable SMS confirmation.
6. Test student signup/login, duplicate numbers, wrong name/specialty/region/category, staff login, reset request, authorized-only reset, and password change.
7. Do not merge to `main` or deploy production until tests pass.
