-- Reproducible roster-driven student assignment and complete semester workflow.
-- Default supervisors imported from seven approved specialty Excel workbooks.

alter table public.student_profiles
  add column if not exists assigned_supervisor_id bigint references public.public_supervisors(id) on delete set null,
  add column if not exists supervisor_assignment_source text not null default 'unassigned',
  add column if not exists roster_supervisor_source_name text,
  add column if not exists roster_supervisor_mapping_status text not null default 'not_in_roster';

alter table public.student_profiles drop constraint if exists student_profiles_supervisor_assignment_source_check;
alter table public.student_profiles add constraint student_profiles_supervisor_assignment_source_check
  check (supervisor_assignment_source in ('roster','manual','unassigned'));
alter table public.student_profiles drop constraint if exists student_profiles_roster_supervisor_mapping_status_check;
alter table public.student_profiles add constraint student_profiles_roster_supervisor_mapping_status_check
  check (roster_supervisor_mapping_status in ('mapped','unmapped','conflict','not_in_roster'));

create table if not exists public.student_roster_supervisor_map (
  university_number text primary key,
  default_supervisor_id bigint references public.public_supervisors(id) on delete set null,
  source_supervisor_name text not null,
  mapping_status text not null check (mapping_status in ('mapped','unmapped','conflict')),
  updated_at timestamptz not null default now()
);
alter table public.student_roster_supervisor_map enable row level security;
revoke all on public.student_roster_supervisor_map from anon,authenticated;

insert into public.student_roster_supervisor_map(university_number,default_supervisor_id,source_supervisor_name,mapping_status)
select x.university_number,x.default_supervisor_id,x.source_supervisor_name,x.mapping_status
from jsonb_to_recordset('[{"university_number":"1206170365","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1206170844","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1206180692","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1206181004","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1206192232","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1206192589","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1206200190","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"1206200800","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1206211484","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1206211699","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1206211744","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1206211785","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1206212038","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1206212316","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1206212435","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1206212729","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1206212791","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1206212856","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1206212880","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1206212926","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1206212934","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1206220011","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1206220039","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1206220047","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1206220063","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"1206220080","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1206220217","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220121122","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220242","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220220258","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220220263","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220220303","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220340","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1220220365","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220366","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220220370","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220220406","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220220414","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220475","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220518","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220523","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220549","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220220569","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220220608","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1220220646","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220731","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220220768","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220220785","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220220829","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220220835","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220220869","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220220872","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220894","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220220898","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220220916","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1220220937","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220220948","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220220971","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220221017","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220221027","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220221084","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1220221086","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220221093","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1220221095","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220221117","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220221125","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220221169","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220221274","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220221318","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220221335","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220221367","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220221438","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220221483","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220221514","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220221519","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220221550","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220221601","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220221635","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220221664","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220221665","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220221688","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220230006","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220230007","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220230024","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220230036","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220230073","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220230114","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220230226","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220230235","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220230353","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220230383","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220230439","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220230440","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220230501","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220230524","default_supervisor_id":1,"source_supervisor_name":"احمد سعيد احمد دوابه","mapping_status":"mapped"},{"university_number":"1220230599","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220230633","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220230688","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220230698","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220230712","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220230777","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220230858","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220230868","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220230881","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220230894","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220230933","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220230947","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220230975","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220230999","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220231040","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220231044","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220231133","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220231260","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220231343","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220231405","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220241490","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220250029","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220250037","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250071","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250073","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250104","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220250189","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220250226","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220250228","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220250237","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250243","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250269","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250319","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220250321","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250350","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220250360","default_supervisor_id":null,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز / موسى كليب محمد ابو مصطفى","mapping_status":"conflict"},{"university_number":"1220250364","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250387","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220250388","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250396","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250407","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250444","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250448","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250485","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250510","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220250518","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220250543","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250642","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220250667","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250688","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250709","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220250793","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220250839","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220250856","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"1220250858","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250864","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"1220250955","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250978","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220250987","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220250997","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251014","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220251032","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220251036","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220251111","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220251131","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220251137","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220251187","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220251192","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220251238","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220251239","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251265","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"1220251430","default_supervisor_id":null,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز / موسى كليب محمد ابو مصطفى","mapping_status":"conflict"},{"university_number":"1220251437","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220251443","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220251453","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251454","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251461","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251472","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220251495","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"1220251498","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220251501","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251508","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251513","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251555","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220251609","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220251656","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251758","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251793","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220251854","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220251900","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220251903","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220251907","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220251922","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"1220251972","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"1220252032","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220252124","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"1220252128","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220252168","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220252247","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"1220252273","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220252324","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220252453","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"1220252469","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220252472","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"1220252478","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220252610","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220252653","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220252684","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220252742","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220252785","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220252800","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"1220252852","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220252856","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"1220253007","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"1220253045","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220253142","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220253163","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220253211","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220253258","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220253385","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"1220253467","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220253514","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220253538","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220253561","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"1220253589","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"1220253597","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"1220253608","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"1220253638","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220253644","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"1220253698","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"1220253733","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220253818","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"1220253884","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220253897","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220254001","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220260001","default_supervisor_id":12,"source_supervisor_name":"عمر محمد خليل النجار","mapping_status":"mapped"},{"university_number":"1220260241","default_supervisor_id":11,"source_supervisor_name":"احمد فرج احمد ابو جزر","mapping_status":"mapped"},{"university_number":"1220260377","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"1220260442","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220261105","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"1220261177","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"1220261364","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"1220261439","default_supervisor_id":2,"source_supervisor_name":"احمد عبد المجيد احمد الحسنات","mapping_status":"mapped"},{"university_number":"2206150290","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2206180142","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2206180990","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2206191833","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2206192116","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2206192182","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2206192245","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2206200682","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2206200749","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2206201127","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2206211649","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2206211908","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2206211991","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2206212153","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2206212604","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2206212721","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2206220007","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2206220149","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2206220166","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2206220212","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2206222993","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220090674","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220120068","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220220239","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220220283","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220220355","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220220373","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220391","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220220436","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220220442","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220220444","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220220445","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220220448","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220220449","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220220473","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220220497","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220524","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220220525","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220554","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220220583","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220220589","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220220596","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220220614","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220220632","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220220637","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"2220220648","default_supervisor_id":null,"source_supervisor_name":"الاء ابراهيم محمد الهور","mapping_status":"unmapped"},{"university_number":"2220220654","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220220664","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220220676","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220677","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220690","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220220718","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220728","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220741","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220755","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220756","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220220776","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220220794","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220220822","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220220833","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220220906","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220220960","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220220986","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220221034","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220221037","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220221182","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220221304","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220221313","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220221329","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220221334","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220221365","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220221402","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220221414","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220221521","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220221529","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220221544","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220221661","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230008","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230020","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220230043","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220230070","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220230077","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220230079","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220230082","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220230102","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220230194","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230204","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220230231","default_supervisor_id":9,"source_supervisor_name":"نبيل سليم حمدان الاغا","mapping_status":"mapped"},{"university_number":"2220230233","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220230251","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220230265","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220230285","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220230292","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220230296","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220230310","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220230324","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220230358","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220230362","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220230369","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220230374","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220230394","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230395","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230414","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220230451","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220230453","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220230463","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220230470","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230480","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220230492","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220230497","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220230530","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230545","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230548","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220230556","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220230585","default_supervisor_id":null,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز / موسى كليب محمد ابو مصطفى","mapping_status":"conflict"},{"university_number":"2220230594","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220230638","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230648","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220230715","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220230716","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220230720","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220230728","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220230736","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220230771","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220230778","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220230782","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220230800","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220230825","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220230841","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220230904","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230909","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220230925","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220230928","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220230967","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220231003","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220231020","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220231030","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220231031","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220231096","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220231112","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220231124","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220231155","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220231174","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220231179","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220231190","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220231209","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220231216","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220231224","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220231229","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220231230","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220231231","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220231280","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220231298","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220231300","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220231361","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220231365","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220231397","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220231418","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220231440","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220231452","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220241504","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250004","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220250007","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220250009","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220250024","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220250075","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220250082","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220250092","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220250118","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250187","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220250231","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220250289","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220250347","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220250372","default_supervisor_id":null,"source_supervisor_name":"الاء ابراهيم محمد الهور","mapping_status":"unmapped"},{"university_number":"2220250384","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250389","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220250439","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220250467","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220250468","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250470","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220250492","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220250517","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220250531","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220250534","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220250544","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250554","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220250570","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220250625","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250660","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220250716","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220250719","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220250724","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220250738","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220250745","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220250746","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220250755","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220250762","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220250768","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220250769","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220250774","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220250779","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250780","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220250797","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220250803","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220250809","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220250820","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250840","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220250843","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220250845","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220250863","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220250870","default_supervisor_id":15,"source_supervisor_name":"يوسف سليم احمد ابو زيد","mapping_status":"mapped"},{"university_number":"2220250877","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220250920","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250945","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220250951","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250963","default_supervisor_id":null,"source_supervisor_name":"الاء ابراهيم محمد الهور","mapping_status":"unmapped"},{"university_number":"2220250966","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220250972","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220250985","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220250996","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220251051","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251053","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220251056","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220251061","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220251079","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220251082","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251084","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251087","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220251092","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220251094","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220251103","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220251108","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220251115","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251121","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251124","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220251125","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220251127","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220251153","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220251155","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251178","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220251179","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251181","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220251205","default_supervisor_id":5,"source_supervisor_name":"حازم حميد عوده ابو حميد","mapping_status":"mapped"},{"university_number":"2220251212","default_supervisor_id":null,"source_supervisor_name":"الاء ابراهيم محمد الهور","mapping_status":"unmapped"},{"university_number":"2220251230","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251234","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220251236","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251240","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220251243","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220251248","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251266","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220251275","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220251289","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251310","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220251355","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220251359","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220251370","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251373","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220251380","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251414","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220251415","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220251416","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251557","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251566","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220251573","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251580","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251593","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220251611","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251616","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251626","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220251633","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220251678","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251680","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220251708","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220251715","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220251719","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251735","default_supervisor_id":null,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز / موسى كليب محمد ابو مصطفى","mapping_status":"conflict"},{"university_number":"2220251738","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251743","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251751","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251752","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251794","default_supervisor_id":null,"source_supervisor_name":"الاء ابراهيم محمد الهور","mapping_status":"unmapped"},{"university_number":"2220251802","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220251817","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220251826","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220251839","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251855","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220251895","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251918","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220251956","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220251965","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252010","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220252098","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252108","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220252110","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252120","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220252142","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252240","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252243","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220252245","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220252252","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220252268","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252277","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220252281","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252289","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220252309","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252319","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252322","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252337","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220252340","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252341","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252391","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252430","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252445","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252463","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252492","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220252515","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220252547","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252556","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220252568","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220252624","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220252625","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220252654","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252669","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220252674","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220252696","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220252763","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220252773","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220252775","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252799","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252805","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220252821","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220252823","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252858","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220252868","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220252885","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220252919","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220252949","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220253037","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253169","default_supervisor_id":null,"source_supervisor_name":"الاء ابراهيم محمد الهور","mapping_status":"unmapped"},{"university_number":"2220253173","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253203","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220253221","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220253236","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220253342","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220253381","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220253388","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220253391","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220253422","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253425","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220253451","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253479","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220253505","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220253530","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253568","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253600","default_supervisor_id":14,"source_supervisor_name":"عمار عبد الرحمن محمد الهباش","mapping_status":"mapped"},{"university_number":"2220253625","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220253651","default_supervisor_id":4,"source_supervisor_name":"رغده ايمن اسماعيل الشيخ على","mapping_status":"mapped"},{"university_number":"2220253674","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220253694","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253701","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220253746","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220253758","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220253809","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220253845","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220253849","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253866","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220253875","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220253883","default_supervisor_id":8,"source_supervisor_name":"موسى كليب محمد ابو مصطفى","mapping_status":"mapped"},{"university_number":"2220253887","default_supervisor_id":7,"source_supervisor_name":"اسلام توفيق محمد عبد العزيز","mapping_status":"mapped"},{"university_number":"2220253926","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220253957","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220260015","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220260175","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220260205","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220260252","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220260448","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220260601","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220260647","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220260664","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220260682","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220260911","default_supervisor_id":13,"source_supervisor_name":"سهام غازى عبد ربه ابو عازره","mapping_status":"mapped"},{"university_number":"2220260924","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220261021","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220261091","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"},{"university_number":"2220261181","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220261292","default_supervisor_id":17,"source_supervisor_name":"نائل عبد على النعيزى","mapping_status":"mapped"},{"university_number":"2220261342","default_supervisor_id":6,"source_supervisor_name":"احمد تيسير ابراهيم الطويل","mapping_status":"mapped"},{"university_number":"2220261350","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220261372","default_supervisor_id":16,"source_supervisor_name":"عثمان محمد عثمان العثمانى","mapping_status":"mapped"},{"university_number":"2220261479","default_supervisor_id":3,"source_supervisor_name":"فؤاد محمد فؤاد لظن","mapping_status":"mapped"},{"university_number":"2220261548","default_supervisor_id":10,"source_supervisor_name":"يسرى شريف محمود حمد","mapping_status":"mapped"}]'::jsonb) as x(
 university_number text,default_supervisor_id bigint,source_supervisor_name text,mapping_status text
)
on conflict(university_number) do update set
 default_supervisor_id=excluded.default_supervisor_id,
 source_supervisor_name=excluded.source_supervisor_name,
 mapping_status=excluded.mapping_status,
 updated_at=now();

-- Administrative sciences are handled by one designated supervisor across all three specialties.
update public.student_roster_supervisor_map
set default_supervisor_id=13,updated_at=now()
where default_supervisor_id in (10,11,17);

-- Child education roster rows naming an unlisted supervisor are aligned to the approved active child-education supervisor.
update public.student_roster_supervisor_map
set default_supervisor_id=16,mapping_status='mapped',updated_at=now()
where mapping_status='unmapped' and source_supervisor_name ilike '%الاء%';

create table if not exists public.student_assignment_audit (
 id bigserial primary key,
 student_user_id uuid not null references auth.users(id) on delete cascade,
 semester_code text,
 from_supervisor_user_id uuid references auth.users(id) on delete set null,
 to_supervisor_user_id uuid references auth.users(id) on delete set null,
 action text not null check(action in ('auto_assign','manual_assign','reassign','remove')),
 reason text,
 changed_by uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now()
);
alter table public.student_assignment_audit enable row level security;
revoke all on public.student_assignment_audit from anon;
grant select on public.student_assignment_audit to authenticated;
drop policy if exists department_head_reads_student_assignment_audit on public.student_assignment_audit;
create policy department_head_reads_student_assignment_audit on public.student_assignment_audit
 for select to authenticated using (public.has_staff_role(array['admin','department_head']::text[]));
create index if not exists idx_student_assignment_audit_student on public.student_assignment_audit(student_user_id,created_at desc);
create unique index if not exists uq_supervisor_assignments_student_semester
 on public.supervisor_assignments(student_user_id,semester_code) where semester_code is not null;

CREATE OR REPLACE FUNCTION public.apply_roster_supervisor_default()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_supervisor_id bigint;
  v_source_name text;
  v_mapping_status text;
  v_supervisor_name text;
  v_supervisor_phone text;
begin
  if tg_op = 'INSERT' or new.university_number is distinct from old.university_number then
    select m.default_supervisor_id, m.source_supervisor_name, m.mapping_status
      into v_supervisor_id, v_source_name, v_mapping_status
    from public.student_roster_supervisor_map m
    where m.university_number = new.university_number
    limit 1;

    if found then
      new.roster_supervisor_source_name := v_source_name;
      new.roster_supervisor_mapping_status := v_mapping_status;
      if new.assigned_supervisor_id is null
         and coalesce(new.supervisor_assignment_source,'unassigned') = 'unassigned'
         and v_mapping_status = 'mapped' then
        new.assigned_supervisor_id := v_supervisor_id;
        new.supervisor_assignment_source := 'roster';
      end if;
    else
      new.roster_supervisor_source_name := null;
      new.roster_supervisor_mapping_status := 'not_in_roster';
    end if;
  end if;

  if new.assigned_supervisor_id is not null then
    select ps.name, ps.phone into v_supervisor_name, v_supervisor_phone
    from public.public_supervisors ps where ps.id = new.assigned_supervisor_id;
    if found then
      new.supervisor_name := v_supervisor_name;
      new.supervisor_phone := v_supervisor_phone;
    end if;
  elsif coalesce(new.supervisor_assignment_source,'unassigned') = 'unassigned' then
    new.supervisor_name := null;
    new.supervisor_phone := null;
  end if;
  return new;
end;
$function$


CREATE OR REPLACE FUNCTION public.assign_training_supervisor(p_supervisor_user_id uuid, p_student_user_id uuid, p_specialty_id bigint, p_training_entity_id bigint)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_assignment_id bigint;
  v_student record;
  v_supervisor record;
  v_student_spec_norm text;
  v_group_norm text;
  v_area_norm text;
  v_region_norm text;
  v_category_norm text;
  v_specialty_ok boolean := false;
  v_region_ok boolean := false;
  v_category_ok boolean := false;
  v_semester text;
  v_old_supervisor uuid;
begin
  if not public.has_staff_role(array['admin','department_head']) then
    raise exception 'Not authorized to assign supervisors';
  end if;

  select sp.user_id, sp.gender, sp.specialty_id, sp.eligibility_status,
         sp.completed_hours, sp.student_area, s.name as specialty_name,
         sp.assigned_supervisor_id
    into v_student
  from public.student_profiles sp
  join public.specialties s on s.id = sp.specialty_id
  where sp.user_id = p_student_user_id
  for update;

  if not found then raise exception 'Student profile not found'; end if;
  if p_specialty_id is distinct from v_student.specialty_id then
    raise exception 'Selected specialty does not match the student profile';
  end if;

  if v_student.eligibility_status not in ('approved','exception_approved') then
    raise exception 'Student eligibility has not been approved';
  end if;
  if v_student.eligibility_status = 'approved' and coalesce(v_student.completed_hours,0) < 36 then
    raise exception 'Student has not met the 36-hour eligibility requirement';
  end if;
  if v_student.eligibility_status = 'exception_approved'
     and not exists (
       select 1 from public.hour_evidence_reviews ev
       where ev.student_user_id = p_student_user_id
         and ev.review_status = 'exception_approved'
         and ev.exception_reason is not null
         and length(trim(ev.exception_reason)) > 0
     ) then
    raise exception 'Student exception must be supported by a reviewed, documented evidence record';
  end if;

  if not exists (
    select 1 from public.user_roles ur
    where ur.user_id = p_supervisor_user_id and ur.role = 'supervisor' and ur.is_active is true
  ) then raise exception 'Selected user does not have an active supervisor role'; end if;

  select ps.id, ps.name, ps.region, ps.category, ps.specialty, ps.supervisor_group, ps.is_active
    into v_supervisor
  from public.public_supervisors ps
  where ps.user_id = p_supervisor_user_id limit 1;

  if not found or v_supervisor.is_active is not true then
    raise exception 'Selected supervisor is not actively linked to the supervisor directory';
  end if;

  if p_training_entity_id is not null and not exists (
    select 1 from public.training_entities te
    where te.id = p_training_entity_id and te.is_active is true and te.is_approved is true
  ) then raise exception 'Training entity must be active and approved'; end if;

  v_student_spec_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_student.specialty_name,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));
  v_group_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_supervisor.supervisor_group, v_supervisor.specialty,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));

  if v_student_spec_norm in (
      lower(regexp_replace(translate('إدارة الأعمال','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('السكرتاريا الدولية','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('العلوم المالية والمصرفية','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g'))
    ) then
      v_specialty_ok := v_group_norm = lower(regexp_replace(translate('العلوم الإدارية','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g'));
  else
      v_specialty_ok := v_student_spec_norm = v_group_norm;
  end if;

  if not v_specialty_ok and v_group_norm = lower(regexp_replace(
      translate('العلوم التكنولوجية','أإآٱىؤئة','اااايويه'),
      '[[:space:]_/-]+','','g')) then
    v_specialty_ok := v_student_spec_norm in (
      lower(regexp_replace(translate('أمن المعلومات','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('التصميم الجرافيكي','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('الوسائط المتعددة','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('برمجة تطبيقات الهواتف الذكية','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('تكنولوجيا المعلومات والاتصالات','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g'))
    );
  elsif not v_specialty_ok and v_group_norm = lower(regexp_replace(
      translate('العلوم الإدارية','أإآٱىؤئة','اااايويه'),
      '[[:space:]_/-]+','','g')) then
    v_specialty_ok := v_student_spec_norm in (
      lower(regexp_replace(translate('إدارة الأعمال','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('السكرتاريا الدولية','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('العلوم المالية والمصرفية','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g'))
    );
  elsif not v_specialty_ok and v_group_norm = lower(regexp_replace(
      translate('العلوم الإعلامية','أإآٱىؤئة','اااايويه'),
      '[[:space:]_/-]+','','g')) then
    v_specialty_ok := v_student_spec_norm in (
      lower(regexp_replace(translate('العلاقات العامة والإعلام','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g')),
      lower(regexp_replace(translate('الصحافة الإلكترونية','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g'))
    );
  elsif not v_specialty_ok and v_group_norm = lower(regexp_replace(
      translate('العلوم التربوية','أإآٱىؤئة','اااايويه'),
      '[[:space:]_/-]+','','g')) then
    v_specialty_ok := v_student_spec_norm = lower(regexp_replace(
      translate('تربية الطفل','أإآٱىؤئة','اااايويه'),'[[:space:]_/-]+','','g'));
  end if;
  if not v_specialty_ok then raise exception 'Supervisor specialty group does not match the student specialty'; end if;

  v_category_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_supervisor.category,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));
  if v_category_norm like '%جميع%' or v_category_norm like '%طلابوطالبات%' or v_category_norm like '%كلاهما%' then
    v_category_ok := true;
  elsif v_student.gender = 'male' then
    v_category_ok := (v_category_norm like '%طلاب%' and v_category_norm not like '%طالبات%') or v_category_norm like '%ذكور%';
  elsif v_student.gender = 'female' then
    v_category_ok := v_category_norm like '%طالبات%' or v_category_norm like '%اناث%';
  end if;
  if not v_category_ok then raise exception 'Supervisor category does not match the student gender'; end if;

  v_area_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_student.student_area,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));
  v_region_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_supervisor.region,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));

  if v_area_norm = '' or v_region_norm = '' then
    v_region_ok := false;
  elsif v_region_norm like '%مناطق%' or v_region_norm like '%جميع%' or v_region_norm = 'الكل' then
    v_region_ok := true;
  elsif v_area_norm like '%غزه%' or v_area_norm like '%شمال%' then
    v_region_ok := v_region_norm like '%غزه%' or v_region_norm like '%شمال%' or v_region_norm like '%شفاء%';
  elsif v_area_norm like '%وسطي%' then
    v_region_ok := v_region_norm like '%وسطي%' or v_region_norm like '%مغازي%' or v_region_norm like '%ديرالبلح%' or v_region_norm like '%نصيرات%';
  elsif v_area_norm like '%جنوب%' or v_area_norm like '%خانيونس%' or v_area_norm like '%رفح%' then
    v_region_ok := v_region_norm like '%جنوب%' or v_region_norm like '%خانيونس%' or v_region_norm like '%رفح%';
  else
    v_region_ok := position(v_area_norm in v_region_norm) > 0;
  end if;
  if not v_region_ok then raise exception 'Supervisor region does not cover the student training area'; end if;

  select semester_code into v_semester from public.academic_semesters
  where is_active is true order by start_date desc limit 1;
  if v_semester is null then raise exception 'No active academic semester is configured'; end if;

  select id, supervisor_user_id into v_assignment_id, v_old_supervisor
  from public.supervisor_assignments
  where student_user_id = p_student_user_id and semester_code = v_semester
  order by created_at desc limit 1 for update;

  if v_assignment_id is null then
    insert into public.supervisor_assignments
      (supervisor_user_id, student_user_id, specialty_id, training_entity_id, assigned_by, semester_code)
    values
      (p_supervisor_user_id, p_student_user_id, p_specialty_id, p_training_entity_id, (select auth.uid()), v_semester)
    on conflict (supervisor_user_id, student_user_id)
    do update set specialty_id = excluded.specialty_id,
                  training_entity_id = excluded.training_entity_id,
                  semester_code = excluded.semester_code,
                  assigned_by = excluded.assigned_by
    returning id into v_assignment_id;
  else
    update public.supervisor_assignments
    set supervisor_user_id = p_supervisor_user_id,
        specialty_id = p_specialty_id,
        training_entity_id = p_training_entity_id,
        assigned_by = (select auth.uid())
    where id = v_assignment_id;
  end if;

  update public.student_profiles
  set assigned_supervisor_id = v_supervisor.id,
      supervisor_assignment_source = 'manual',
      supervisor_name = v_supervisor.name
  where user_id = p_student_user_id;

  insert into public.student_assignment_audit
    (student_user_id, semester_code, from_supervisor_user_id, to_supervisor_user_id, action, reason, changed_by)
  values
    (p_student_user_id, v_semester, v_old_supervisor, p_supervisor_user_id,
     case when v_old_supervisor is null then 'manual_assign' else 'reassign' end,
     'إسناد/تغيير يدوي من رئيس القسم', (select auth.uid()));

  return v_assignment_id;
end;
$function$


CREATE OR REPLACE FUNCTION public.auto_assign_eligible_student_to_selected_supervisor()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_supervisor record;
  v_specialty_name text;
  v_group text;
  v_area_norm text;
  v_region_norm text;
  v_category_norm text;
  v_specialty_norm text;
  v_group_norm text;
  v_region_ok boolean := false;
  v_category_ok boolean := false;
  v_semester text;
  v_assignment_id bigint;
  v_old_supervisor uuid;
begin
  if coalesce(new.registration_status,'') <> 'approved'
     or new.assigned_supervisor_id is null
     or new.specialty_id is null
     or not (
       (new.eligibility_status = 'approved' and coalesce(new.completed_hours,0) >= 36)
       or
       (new.eligibility_status = 'exception_approved' and exists (
         select 1 from public.hour_evidence_reviews ev
         where ev.student_user_id = new.user_id
           and ev.review_status = 'exception_approved'
           and nullif(trim(coalesce(ev.exception_reason,'')), '') is not null
       ))
     ) then
    return new;
  end if;

  select ps.id, ps.user_id, ps.name, ps.region, ps.category,
         ps.specialty, ps.supervisor_group, ps.is_active
    into v_supervisor
  from public.public_supervisors ps
  where ps.id = new.assigned_supervisor_id
    and ps.is_active is true
    and ps.user_id is not null
  limit 1;

  if not found then return new; end if;

  if not exists (
    select 1 from public.user_roles ur
    where ur.user_id = v_supervisor.user_id
      and ur.role = 'supervisor'
      and ur.is_active is true
  ) then return new; end if;

  select s.name into v_specialty_name
  from public.specialties s where s.id = new.specialty_id;
  if v_specialty_name is null then return new; end if;

  v_group := case
    when v_specialty_name in (
      'أمن المعلومات','التصميم الجرافيكي','الوسائط المتعددة',
      'برمجة تطبيقات الهواتف الذكية','تكنولوجيا المعلومات والاتصالات'
    ) then 'العلوم التكنولوجية'
    when v_specialty_name in ('إدارة الأعمال','السكرتاريا الدولية','العلوم المالية والمصرفية')
      then 'العلوم الإدارية'
    when v_specialty_name in ('العلاقات العامة والإعلام','الصحافة الإلكترونية')
      then 'العلوم الإعلامية'
    when v_specialty_name = 'تربية الطفل' then 'العلوم التربوية'
    when v_specialty_name = 'علوم التربية البدنية' then 'علوم التربية البدنية'
    when v_specialty_name = 'العلاج الوظيفي' then 'العلاج الوظيفي'
    else v_specialty_name
  end;

  v_specialty_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_supervisor.supervisor_group, v_supervisor.specialty,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));
  v_group_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_group,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));
  if v_specialty_norm <> v_group_norm then return new; end if;

  v_category_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_supervisor.category,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));
  if v_category_norm like '%جميع%' or v_category_norm like '%طلابوطالبات%'
     or v_category_norm like '%كلاهما%' then
    v_category_ok := true;
  elsif new.gender = 'female' then
    v_category_ok := v_category_norm like '%طالبات%' or v_category_norm like '%اناث%';
  elsif new.gender = 'male' then
    v_category_ok := (v_category_norm like '%طلاب%' and v_category_norm not like '%طالبات%')
      or v_category_norm like '%ذكور%';
  end if;
  if not v_category_ok then return new; end if;

  v_area_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(new.student_area,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));
  v_region_norm := lower(regexp_replace(
    translate(regexp_replace(trim(coalesce(v_supervisor.region,'')), '[ًٌٍَُِّْٰـ]', '', 'g'),
              'أإآٱىؤئة', 'اااايويه'),
    '[[:space:]_/-]+', '', 'g'));

  if v_area_norm = '' or v_region_norm = '' then
    v_region_ok := false;
  elsif v_region_norm like '%مناطق%' or v_region_norm like '%جميع%' or v_region_norm = 'الكل' then
    v_region_ok := true;
  elsif v_area_norm like '%غزه%' or v_area_norm like '%شمال%' then
    v_region_ok := v_region_norm like '%غزه%' or v_region_norm like '%شمال%' or v_region_norm like '%شفاء%';
  elsif v_area_norm like '%وسطي%' then
    v_region_ok := v_region_norm like '%وسطي%' or v_region_norm like '%مغازي%' or v_region_norm like '%ديرالبلح%' or v_region_norm like '%نصيرات%';
  elsif v_area_norm like '%جنوب%' or v_area_norm like '%خانيونس%' or v_area_norm like '%رفح%' then
    v_region_ok := v_region_norm like '%جنوب%' or v_region_norm like '%خانيونس%' or v_region_norm like '%رفح%';
  else
    v_region_ok := position(v_area_norm in v_region_norm) > 0;
  end if;
  if not v_region_ok then return new; end if;

  select semester_code into v_semester
  from public.academic_semesters where is_active is true
  order by start_date desc limit 1;
  if v_semester is null then return new; end if;

  select id, supervisor_user_id into v_assignment_id, v_old_supervisor
  from public.supervisor_assignments
  where student_user_id = new.user_id and semester_code = v_semester
  order by created_at desc limit 1
  for update;

  if v_assignment_id is not null then
    if v_old_supervisor is distinct from v_supervisor.user_id then
      update public.supervisor_assignments
      set supervisor_user_id = v_supervisor.user_id,
          specialty_id = new.specialty_id,
          assigned_by = null
      where id = v_assignment_id;

      insert into public.student_assignment_audit
        (student_user_id, semester_code, from_supervisor_user_id, to_supervisor_user_id, action, reason, changed_by)
      values
        (new.user_id, v_semester, v_old_supervisor, v_supervisor.user_id, 'auto_assign',
         'تحديث الإسناد التلقائي وفق المشرف المحدد في كشف الطلاب', null);
    end if;
  else
    insert into public.supervisor_assignments
      (supervisor_user_id, student_user_id, specialty_id, training_entity_id, assigned_by, semester_code)
    values
      (v_supervisor.user_id, new.user_id, new.specialty_id, null, null, v_semester)
    on conflict (supervisor_user_id, student_user_id)
    do update set specialty_id = excluded.specialty_id, semester_code = excluded.semester_code
    returning id into v_assignment_id;

    insert into public.student_assignment_audit
      (student_user_id, semester_code, from_supervisor_user_id, to_supervisor_user_id, action, reason, changed_by)
    values
      (new.user_id, v_semester, null, v_supervisor.user_id, 'auto_assign',
       'إسناد تلقائي وفق كشف الطلاب بعد اعتماد التسجيل والأهلية', null);
  end if;

  return new;
end;
$function$


CREATE OR REPLACE FUNCTION public.get_supervisor_assigned_student_details()
 RETURNS TABLE(student_user_id uuid, full_name text, university_number text, phone text, approved_training_entity text, proposed_institution_name text, institution_location text, student_area text, joined_at timestamp with time zone, registration_status text, assignment_id bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if not exists (
  select 1 from public.supervisor_assignments a
  where a.supervisor_user_id=auth.uid() and a.semester_code=(select semester_code from public.academic_semesters where is_active is true order by start_date desc limit 1)
 ) then
  raise exception 'Not authorized to view assigned students';
 end if;
 return query
 select
  a.student_user_id,
  coalesce(p.full_name,'—'),
  coalesce(p.university_number,'—'),
  coalesce(p.phone,'—'),
  coalesce(te.name,''),
  coalesce(pref.proposed_entity_name,''),
  coalesce(pref.proposed_entity_location,''),
  coalesce(pref.student_area,p.student_area,''),
  p.created_at,
  coalesce(p.registration_status,'pending'),
  a.id::bigint
 from public.supervisor_assignments a
 join public.student_profiles p on p.user_id=a.student_user_id
 left join public.student_training_preferences pref on pref.student_user_id=p.user_id
 left join public.training_registration_requests req on req.student_user_id=p.user_id
   and req.request_status in ('approved','exception_approved')
 left join public.training_entities te on te.id=coalesce(pref.preferred_training_entity_id,req.training_entity_id)
 where a.supervisor_user_id=auth.uid() and a.semester_code=(select semester_code from public.academic_semesters where is_active is true order by start_date desc limit 1)
 order by p.full_name;
end;
$function$


CREATE OR REPLACE FUNCTION public.remove_training_supervisor_assignment(p_assignment_id bigint)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_assignment public.supervisor_assignments%rowtype;
begin
  if not public.has_staff_role(array['admin','department_head']::text[]) then
    raise exception 'غير مصرح: إزالة التكليف متاحة لرئيس القسم والإدارة فقط';
  end if;

  select * into v_assignment
  from public.supervisor_assignments
  where id = p_assignment_id
  for update;

  if not found then return false; end if;

  delete from public.supervisor_assignments where id = p_assignment_id;

  update public.student_profiles
  set assigned_supervisor_id = null,
      supervisor_assignment_source = 'unassigned',
      supervisor_name = null,
      supervisor_phone = null,
      updated_at = now()
  where user_id = v_assignment.student_user_id;

  insert into public.student_assignment_audit
    (student_user_id, semester_code, from_supervisor_user_id, to_supervisor_user_id, action, reason, changed_by)
  values
    (v_assignment.student_user_id, v_assignment.semester_code, v_assignment.supervisor_user_id, null,
     'remove', 'إزالة تكليف الإشراف بناءً على قرار رئيس القسم', (select auth.uid()));

  return true;
end;
$function$


CREATE OR REPLACE FUNCTION public.retry_auto_assign_after_supervisor_role()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if new.role = 'supervisor' and new.is_active is true
     and (tg_op = 'INSERT' or old.is_active is distinct from new.is_active) then
    update public.student_profiles sp
       set assigned_supervisor_id = sp.assigned_supervisor_id
     where sp.assigned_supervisor_id in (
       select ps.id from public.public_supervisors ps
       where ps.user_id = new.user_id and ps.is_active is true
     )
       and sp.registration_status = 'approved'
       and (
         (sp.eligibility_status = 'approved' and coalesce(sp.completed_hours,0) >= 36)
         or
         (sp.eligibility_status = 'exception_approved' and exists (
           select 1 from public.hour_evidence_reviews ev
           where ev.student_user_id = sp.user_id
             and ev.review_status = 'exception_approved'
             and nullif(trim(coalesce(ev.exception_reason,'')), '') is not null
         ))
       );
  end if;
  return new;
end;
$function$


CREATE OR REPLACE FUNCTION public.retry_auto_assign_for_linked_supervisor()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  if new.user_id is not null and new.is_active is true
     and (tg_op = 'INSERT' or old.user_id is distinct from new.user_id
          or old.is_active is distinct from new.is_active or old.name is distinct from new.name) then
    update public.student_profiles sp
       set assigned_supervisor_id = new.id
     where sp.assigned_supervisor_id = new.id
       and sp.registration_status = 'approved'
       and (
         (sp.eligibility_status = 'approved' and coalesce(sp.completed_hours,0) >= 36)
         or
         (sp.eligibility_status = 'exception_approved' and exists (
           select 1 from public.hour_evidence_reviews ev
           where ev.student_user_id = sp.user_id
             and ev.review_status = 'exception_approved'
             and nullif(trim(coalesce(ev.exception_reason,'')), '') is not null
         ))
       );
  end if;
  return new;
end;
$function$


CREATE OR REPLACE FUNCTION public.review_student_registration(p_student_user_id uuid, p_status text, p_note text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_number text;
  v_gender text;
  v_specialty_id bigint;
  v_registration_status text;
  v_roster_active boolean;
  v_roster_gender text;
  v_roster_specialty bigint;
begin
  if not public.has_staff_role(array['admin','department_head']) then
    raise exception 'Not authorized to review student registration';
  end if;

  if p_student_user_id is null or p_status not in ('approved','rejected') then
    raise exception 'Invalid student registration decision';
  end if;

  if p_status = 'rejected' and (p_note is null or length(trim(p_note)) = 0) then
    raise exception 'A documented rejection reason is required';
  end if;

  select sp.university_number, sp.gender, sp.specialty_id, sp.registration_status
    into v_number, v_gender, v_specialty_id, v_registration_status
  from public.student_profiles sp
  where sp.user_id = p_student_user_id
  for update;

  if not found then
    raise exception 'Student profile not found';
  end if;

  if v_registration_status <> 'pending' then
    raise exception 'Student registration has already been reviewed';
  end if;

  if not exists (
    select 1 from public.user_roles ur
    where ur.user_id = p_student_user_id
      and ur.role = 'student'
  ) then
    raise exception 'Student account role was not found';
  end if;

  if p_status = 'approved' then
    select r.is_active, r.gender, r.specialty_id
      into v_roster_active, v_roster_gender, v_roster_specialty
    from public.eligible_student_roster r
    where r.university_number = v_number;

    if not found or v_roster_active is distinct from true then
      raise exception 'Student number is not active in the approved roster';
    end if;

    if v_roster_gender is distinct from v_gender
       or (v_roster_specialty is not null and v_roster_specialty is distinct from v_specialty_id) then
      raise exception 'Student profile does not match the approved roster';
    end if;
  end if;

  update public.student_profiles
  set registration_status = p_status,
      registration_review_note = nullif(trim(p_note), ''),
      registration_reviewed_by = (select auth.uid()),
      registration_reviewed_at = now(),
      updated_at = now()
  where user_id = p_student_user_id;

  update public.user_roles
  set is_active = (p_status = 'approved')
  where user_id = p_student_user_id
    and role = 'student';
end;
$function$


CREATE OR REPLACE FUNCTION public.review_supervisor_workload(p_report_id bigint, p_decision text, p_review_note text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_report public.supervisor_workload_reports%rowtype;
  v_action text;
begin
  if not public.has_staff_role(array['admin','department_head']) then
    raise exception 'Only department head or admin may review workload reports';
  end if;
  if p_decision not in ('approved','returned') then raise exception 'Decision must be approved or returned'; end if;
  if p_decision='returned' and nullif(trim(p_review_note),'') is null then
    raise exception 'A reason is required when returning or reopening a report';
  end if;
  select * into v_report from public.supervisor_workload_reports
  where id=p_report_id
    and (report_status='submitted' or (report_status='approved' and p_decision='returned'))
  for update;
  if not found then raise exception 'Report is not eligible for this review action'; end if;

  update public.supervisor_workload_reports
  set report_status=p_decision, reviewed_by=(select auth.uid()), reviewed_at=now(),
      review_note=nullif(trim(p_review_note),''), updated_at=now()
  where id=p_report_id;

  update public.student_semester_evaluations
  set evaluation_status=p_decision, reviewed_by=(select auth.uid()), reviewed_at=now(),
      review_note=nullif(trim(p_review_note),''), updated_at=now()
  where supervisor_user_id=v_report.supervisor_user_id
    and semester_code=v_report.semester_code
    and evaluation_status in ('submitted','approved');

  v_action:=case when p_decision='approved' then 'head_approve' else 'head_return' end;
  insert into public.student_evaluation_audit(evaluation_id,actor_user_id,action,old_values,new_values,reason)
  select e.id,(select auth.uid()),v_action,
    jsonb_build_object('evaluation_status',case when v_report.report_status='approved' then 'approved' else 'submitted' end),
    jsonb_build_object('evaluation_status',p_decision),nullif(trim(p_review_note),'')
  from public.student_semester_evaluations e
  where e.supervisor_user_id=v_report.supervisor_user_id and e.semester_code=v_report.semester_code;
end;
$function$


CREATE OR REPLACE FUNCTION public.save_student_semester_evaluation(p_student_user_id uuid, p_semester_code text, p_portfolio_score numeric, p_supervisor_score numeric, p_institution_score numeric, p_signature_sheet_score numeric, p_evaluation_notes text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
  v_id bigint;
  v_status text;
  v_report_status text;
  v_old jsonb;
  v_new jsonb;
begin
  if not public.has_staff_role(array['supervisor']) then raise exception 'Only an active supervisor may enter evaluation scores'; end if;
  if p_semester_code is null or length(trim(p_semester_code)) not between 3 and 40 then raise exception 'Enter a valid semester code'; end if;
  if not exists(select 1 from public.supervisor_assignments sa where sa.supervisor_user_id=v_uid and sa.student_user_id=p_student_user_id and sa.semester_code=trim(p_semester_code)) then
    raise exception 'Student is not officially assigned to this supervisor';
  end if;
  if p_portfolio_score not between 0 and 40 or p_supervisor_score not between 0 and 30
    or p_institution_score not between 0 and 20 or p_signature_sheet_score not between 0 and 10 then
    raise exception 'Scores exceed the approved rubric';
  end if;

  insert into public.supervisor_workload_reports(supervisor_user_id,semester_code)
  values(v_uid,trim(p_semester_code)) on conflict(supervisor_user_id,semester_code) do nothing;
  select report_status into v_report_status from public.supervisor_workload_reports
  where supervisor_user_id=v_uid and semester_code=trim(p_semester_code) for update;
  if v_report_status not in ('draft','returned') then
    raise exception 'The workload report is submitted or approved and locked; ask the department head to reopen it';
  end if;

  select id,evaluation_status,jsonb_build_object('portfolio_score',portfolio_score,
    'supervisor_score',supervisor_score,'institution_score',institution_score,
    'signature_sheet_score',signature_sheet_score,'evaluation_notes',evaluation_notes)
  into v_id,v_status,v_old
  from public.student_semester_evaluations
  where semester_code=trim(p_semester_code) and student_user_id=p_student_user_id for update;
  if v_id is not null and v_status not in ('draft','returned') then
    raise exception 'Evaluation is submitted or approved and locked; ask the department head to return it';
  end if;

  if v_id is null then
    insert into public.student_semester_evaluations(semester_code,student_user_id,supervisor_user_id,
      portfolio_score,supervisor_score,institution_score,signature_sheet_score,evaluation_notes)
    values(trim(p_semester_code),p_student_user_id,v_uid,p_portfolio_score,p_supervisor_score,
      p_institution_score,p_signature_sheet_score,nullif(trim(p_evaluation_notes),'')) returning id into v_id;
  else
    update public.student_semester_evaluations set supervisor_user_id=v_uid,portfolio_score=p_portfolio_score,
      supervisor_score=p_supervisor_score,institution_score=p_institution_score,
      signature_sheet_score=p_signature_sheet_score,evaluation_notes=nullif(trim(p_evaluation_notes),''),
      updated_at=now() where id=v_id;
  end if;
  v_new:=jsonb_build_object('portfolio_score',p_portfolio_score,'supervisor_score',p_supervisor_score,
    'institution_score',p_institution_score,'signature_sheet_score',p_signature_sheet_score,
    'evaluation_notes',nullif(trim(p_evaluation_notes),''));
  insert into public.student_evaluation_audit(evaluation_id,actor_user_id,action,old_values,new_values)
  values(v_id,v_uid,'supervisor_save',v_old,v_new);
  return v_id;
end;
$function$


CREATE OR REPLACE FUNCTION public.save_supervisor_training_visit(p_student_user_id uuid, p_semester_code text, p_visit_number integer, p_visit_date date, p_visit_type text DEFAULT 'ميدانية'::text, p_visit_notes text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_supervisor uuid := (select auth.uid());
  v_report_status text;
  v_visit_id bigint;
begin
  if not public.has_staff_role(array['supervisor']) then
    raise exception 'Only an assigned supervisor may record visits';
  end if;
  if p_semester_code is null or length(trim(p_semester_code)) not between 3 and 40 then
    raise exception 'Enter the semester label, e.g. 2026-1';
  end if;
  if p_visit_number is null or p_visit_number not between 1 and 4 then
    raise exception 'Visit number must be between 1 and 4';
  end if;
  if p_visit_date is null then
    raise exception 'Visit date is required';
  end if;
  if not exists (
    select 1 from public.supervisor_assignments sa
    where sa.supervisor_user_id = v_supervisor
      and sa.student_user_id = p_student_user_id
  ) then
    raise exception 'This student is not assigned to the current supervisor';
  end if;

  insert into public.supervisor_workload_reports(supervisor_user_id, semester_code)
  values (v_supervisor, trim(p_semester_code))
  on conflict (supervisor_user_id, semester_code) do nothing;

  select wr.report_status into v_report_status
  from public.supervisor_workload_reports wr
  where wr.supervisor_user_id = v_supervisor
    and wr.semester_code = trim(p_semester_code)
  for update;

  if v_report_status not in ('draft','returned') then
    raise exception 'The workload report is already submitted or approved and is locked';
  end if;

  insert into public.supervisor_training_visits
    (supervisor_user_id, student_user_id, semester_code, visit_number, visit_date, visit_type, visit_notes)
  values
    (v_supervisor, p_student_user_id, trim(p_semester_code), p_visit_number,
     p_visit_date, coalesce(nullif(trim(p_visit_type),''),'ميدانية'), nullif(trim(p_visit_notes),''))
  on conflict (student_user_id, semester_code, visit_number)
  do update set
    supervisor_user_id = excluded.supervisor_user_id,
    visit_date = excluded.visit_date,
    visit_type = excluded.visit_type,
    visit_notes = excluded.visit_notes,
    updated_at = now()
  where public.supervisor_training_visits.supervisor_user_id = v_supervisor
  returning id into v_visit_id;

  if v_visit_id is null then
    raise exception 'This visit number is already recorded by another supervisor';
  end if;
  update public.supervisor_workload_reports
  set updated_at = now()
  where supervisor_user_id = v_supervisor and semester_code = trim(p_semester_code);
  return v_visit_id;
end;
$function$


CREATE OR REPLACE FUNCTION public.submit_supervisor_workload(p_semester_code text, p_supervisor_note text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_supervisor uuid := (select auth.uid());
  v_status text;
  v_missing integer;
begin
  if not public.has_staff_role(array['supervisor']) then
    raise exception 'Only a supervisor may submit a workload report';
  end if;
  if p_semester_code is null or length(trim(p_semester_code)) not between 3 and 40 then
    raise exception 'Enter the semester label, e.g. 2026-1';
  end if;
  if not exists (select 1 from public.supervisor_assignments sa where sa.supervisor_user_id=v_supervisor and sa.semester_code=trim(p_semester_code)) then
    raise exception 'No students are assigned to this supervisor';
  end if;
  insert into public.supervisor_workload_reports(supervisor_user_id,semester_code)
  values(v_supervisor,trim(p_semester_code))
  on conflict(supervisor_user_id,semester_code) do nothing;
  select report_status into v_status from public.supervisor_workload_reports
  where supervisor_user_id=v_supervisor and semester_code=trim(p_semester_code) for update;
  if v_status not in ('draft','returned') then raise exception 'This report has already been submitted or approved'; end if;

  select count(*) into v_missing
  from public.supervisor_assignments sa
  where sa.supervisor_user_id=v_supervisor
    and sa.semester_code=trim(p_semester_code)
    and (
      (select count(*) from public.supervisor_training_visits v
       where v.supervisor_user_id=v_supervisor and v.student_user_id=sa.student_user_id
         and v.semester_code=trim(p_semester_code)) < 4
      or not exists(select 1 from public.student_semester_evaluations e
        where e.supervisor_user_id=v_supervisor and e.student_user_id=sa.student_user_id
          and e.semester_code=trim(p_semester_code)
          and e.portfolio_score is not null and e.supervisor_score is not null
          and e.institution_score is not null and e.signature_sheet_score is not null
          and e.evaluation_status in ('draft','returned'))
    );
  if v_missing>0 then
    raise exception 'Cannot submit: % student(s) still need four visits and/or complete evaluation scores',v_missing;
  end if;

  update public.student_semester_evaluations set evaluation_status='submitted',
    submitted_at=now(),updated_at=now()
  where supervisor_user_id=v_supervisor and semester_code=trim(p_semester_code)
    and evaluation_status in ('draft','returned');

  update public.supervisor_workload_reports set supervisor_note=nullif(trim(p_supervisor_note),''),
    report_status='submitted',submitted_at=now(),reviewed_by=null,reviewed_at=null,
    review_note=null,updated_at=now()
  where supervisor_user_id=v_supervisor and semester_code=trim(p_semester_code);
end;
$function$


drop trigger if exists trg_apply_roster_supervisor_default on public.student_profiles;
create trigger trg_apply_roster_supervisor_default before insert or update of university_number,assigned_supervisor_id,supervisor_assignment_source
 on public.student_profiles for each row execute function public.apply_roster_supervisor_default();
drop trigger if exists trg_auto_assign_eligible_student on public.student_profiles;
create trigger trg_auto_assign_eligible_student after insert or update of registration_status,eligibility_status,completed_hours,assigned_supervisor_id,specialty_id,student_area,gender
 on public.student_profiles for each row execute function public.auto_assign_eligible_student_to_selected_supervisor();
drop trigger if exists trg_retry_assign_after_supervisor_role on public.user_roles;
create trigger trg_retry_assign_after_supervisor_role after insert or update on public.user_roles for each row execute function public.retry_auto_assign_after_supervisor_role();
drop trigger if exists trg_retry_assign_after_supervisor_link on public.public_supervisors;
create trigger trg_retry_assign_after_supervisor_link after insert or update on public.public_supervisors for each row execute function public.retry_auto_assign_for_linked_supervisor();

update public.student_profiles sp
set roster_supervisor_source_name=m.source_supervisor_name,
    roster_supervisor_mapping_status=m.mapping_status,
    assigned_supervisor_id=coalesce(
      (select ps.id from public.supervisor_assignments sa join public.academic_semesters sem on sem.semester_code=sa.semester_code and sem.is_active is true
       join public.public_supervisors ps on ps.user_id=sa.supervisor_user_id where sa.student_user_id=sp.user_id order by sa.created_at desc limit 1),
      case when m.mapping_status='mapped' then m.default_supervisor_id else null end),
    supervisor_assignment_source=case
      when exists(select 1 from public.supervisor_assignments sa join public.academic_semesters sem on sem.semester_code=sa.semester_code and sem.is_active is true
       join public.public_supervisors ps on ps.user_id=sa.supervisor_user_id where sa.student_user_id=sp.user_id and ps.id is distinct from m.default_supervisor_id) then 'manual'
      when m.mapping_status='mapped' then 'roster' else 'unassigned' end
from public.student_roster_supervisor_map m where m.university_number=sp.university_number;

update public.student_profiles sp
set roster_supervisor_mapping_status='not_in_roster',roster_supervisor_source_name=null,
    assigned_supervisor_id=null,supervisor_assignment_source='unassigned',supervisor_name=null,supervisor_phone=null
where not exists(select 1 from public.student_roster_supervisor_map m where m.university_number=sp.university_number)
and not exists(select 1 from public.supervisor_assignments sa join public.academic_semesters sem on sem.semester_code=sa.semester_code and sem.is_active is true where sa.student_user_id=sp.user_id);

revoke all on function public.apply_roster_supervisor_default() from public,anon;
revoke all on function public.auto_assign_eligible_student_to_selected_supervisor() from public,anon,authenticated;
revoke all on function public.retry_auto_assign_after_supervisor_role() from public,anon,authenticated;
revoke all on function public.retry_auto_assign_for_linked_supervisor() from public,anon,authenticated;
revoke all on function public.assign_training_supervisor(uuid,uuid,bigint,bigint) from public,anon;
grant execute on function public.assign_training_supervisor(uuid,uuid,bigint,bigint) to authenticated;
revoke all on function public.remove_training_supervisor_assignment(bigint) from public,anon;
grant execute on function public.remove_training_supervisor_assignment(bigint) to authenticated;
