# Field Training System — Integration Audit (2026-10-28)

This document records verified frontend findings from `index.html` on the `main` branch. It is an implementation checklist, not proof that the live Supabase project has the same schema.

## Verified in the current frontend

- Student self-registration calls the Supabase Edge Function `student-auth`.
- Student registration validates the university number prefix in the browser (122 / 222) and requires a selected supervisor.
- Supervisor directory reads `public_supervisors` and uses name, region, category, specialty, active state, and optionally phone.
- Student profiles are read from `student_profiles`.
- Assignments are read from `supervisor_assignments`.
- Workload screen reads `supervisor_training_visits` and `supervisor_workload_reports`, and calls RPCs for save/submit/review.
- Evaluation form templates calculate grades and print, but the current code explicitly says formal database saving is not enabled.
- The UI has no XLSX/CSV roster import/parser in the current `index.html`.
- The public supervisor seed contains 17 names, but is not a substitute for an authoritative, editable staff register.

## Required end-to-end work

1. **Student roster import**: upload Excel/CSV, preview rows, validate duplicates, 122/222 prefix, specialty, region, and verified completed hours. Import must stage eligible students safely; it must not create authentication accounts from browser code using privileged credentials.
2. **Supervisor register**: authorized department-head workflow to create/update supervisor records, regions, specialties, category, active status, and securely map each supervisor to their authenticated user ID.
3. **Assignments**: authorized allocation workflow linking a verified student profile, supervisor auth user, specialty, training entity, semester, and assignment status. Prevent duplicate active assignments and enforce eligibility server-side.
4. **Workload**: calculate four required visits per assigned student from saved assignments and visits; supervisor submits report; department head approves or returns it with notes. Every write must be protected by database policies/RPC authorization.
5. **Evaluations**: persist evaluator, student, specialty, form type, criteria scores, total, normalized score, notes, status, and timestamps; validate score limits server-side and enforce the expected 40/20/30/10 grading structure where applicable.
6. **Testing**: test successful and denied operations using student, supervisor, and department-head accounts; verify RLS and database constraints; then verify the deployed Cloudflare URL reflects the intended commit.

## Backend artifacts that must be checked before making schema-dependent writes

The expected SQL schema/migration files and some Edge Function source paths were not found in the repository paths inspected during this audit. Do not assume a table, RPC, policy, or Edge Function exists merely because the frontend calls it. Retrieve the actual current Supabase schema/functions or locate the authoritative migrations before applying changes.

## Acceptance criteria

- A roster file can be previewed and validated before any rows are written.
- Imported student eligibility is enforced server-side, not only in JavaScript.
- Every active student assignment resolves to a valid student and authenticated supervisor.
- A supervisor sees only assigned students and can submit visits/report for the selected semester.
- Department head can review/return/approve workload reports, with an audit trail.
- Evaluation scores persist and can be retrieved after sign-out/sign-in.
- No privileged Supabase key is embedded in the public website.
