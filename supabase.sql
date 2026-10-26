-- Supabase > SQL Editor > paste this whole file > Run

create table if not exists site_data (
  id text primary key,
  data jsonb not null default '{}',
  updated_at timestamptz default now()
);

alter table public.site_data enable row level security;

-- This table contains the public salon catalog. Replace any previous table
-- policies so older restrictive policies cannot continue blocking writes.
do $$
declare
  existing_policy record;
begin
  for existing_policy in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'site_data'
  loop
    execute format('drop policy %I on public.site_data', existing_policy.policyname);
  end loop;
end;
$$;

revoke all on table public.site_data from anon, authenticated;
grant select on table public.site_data to anon, authenticated;
grant insert, update on table public.site_data to authenticated;

-- Visitors can read. A user signed in through Supabase Auth (email/password)
-- can insert or update the single published site row; no manually assigned
-- app_metadata role is required.
create policy "public read" on public.site_data
  for select to anon, authenticated using (true);
create policy "signed-in insert" on public.site_data
  for insert to authenticated with check (id = 'main');
create policy "signed-in update" on public.site_data
  for update to authenticated using (id = 'main')
  with check (id = 'main');

-- Seed the built-in catalog on first setup, or fill an existing empty row.
-- Re-running this script will not overwrite data that is already populated.
insert into site_data (id, data) values (
  'main',
  $seed$
  {
    "services": [
      {
        "name": "Men",
        "groups": [
          {
            "title": "Grooming",
            "note": "",
            "items": [
              {"name":"Hair Cut","price":500,"on":true},
              {"name":"Beard","price":300,"on":true},
              {"name":"Clean Shave","price":200,"on":true},
              {"name":"Head Shave","price":500,"on":true},
              {"name":"Hair Wash","price":200,"on":true},
              {"name":"Hair Styling","price":100,"on":true},
              {"name":"Head Massage","price":500,"on":true}
            ]
          },
          {
            "title": "Hair Treatment",
            "note": "",
            "items": [
              {"name":"Hair Spa","price":1000,"on":true},
              {"name":"Premium Spa","price":1500,"on":true},
              {"name":"Botox","price":2500,"on":true},
              {"name":"Keratin","price":2000,"on":true},
              {"name":"Nanoplastia","price":2500,"on":true},
              {"name":"Scalp Detox","price":1200,"on":true},
              {"name":"Anti Dandruff","price":1200,"on":true},
              {"name":"Hair Fall Control","price":1200,"on":true}
            ]
          },
          {
            "title": "Hair Colour",
            "note": "",
            "items": [
              {"name":"Global Hair Colour","price":1000,"on":true},
              {"name":"Highlights","price":2500,"on":true},
              {"name":"Bleach","price":3000,"on":true}
            ]
          }
        ]
      },
      {
        "name": "Women",
        "groups": [
          {
            "title": "Grooming",
            "note": "Prices vary with hair length.",
            "items": [
              {"name":"Hair Cut","price":700,"on":true},
              {"name":"Hair Trimming","price":400,"on":true},
              {"name":"Hair Wash","price":300,"on":true},
              {"name":"Blowdry","price":200,"on":true},
              {"name":"Premium Wash & Blowdry","price":600,"on":true},
              {"name":"Tongs","price":700,"on":true},
              {"name":"Ironing","price":700,"on":true}
            ]
          },
          {
            "title": "Hair Treatment",
            "note": "According to hair length.",
            "items": [
              {"name":"Hair Spa","price":1500,"on":true},
              {"name":"Premium Spa","price":2500,"on":true},
              {"name":"Botox","price":5000,"on":true},
              {"name":"Keratin","price":4000,"on":true},
              {"name":"Nanoplastia","price":5000,"on":true},
              {"name":"Scalp Detox","price":1000,"on":true},
              {"name":"Anti Dandruff","price":1500,"on":true},
              {"name":"Hair Fall Control","price":1500,"on":true}
            ]
          },
          {
            "title": "Hair Colour",
            "note": "According to hair length.",
            "items": [
              {"name":"Root Touchup","price":1200,"on":true},
              {"name":"Global Hair Colour","price":3500,"on":true},
              {"name":"Highlights","price":4500,"on":true},
              {"name":"Partial Highlights","price":2500,"on":true},
              {"name":"Ombre","price":4500,"on":true},
              {"name":"Balayage","price":4500,"on":true},
              {"name":"Bleach","price":2000,"on":true}
            ]
          }
        ]
      },
      {
        "name": "Beauty",
        "groups": [
          {
            "title": "Facials",
            "note": "",
            "items": [
              {"name":"Express Facial","price":1500,"on":true},
              {"name":"Premium Facial","price":2500,"on":true},
              {"name":"Hydra Facial","price":5000,"on":true},
              {"name":"Clean Up","price":1000,"on":true},
              {"name":"D-Tan","price":750,"on":true}
            ]
          },
          {
            "title": "Threading",
            "note": "",
            "items": [
              {"name":"Eyebrow","price":100,"on":true},
              {"name":"Upper Lips","price":50,"on":true},
              {"name":"Forehead","price":50,"on":true},
              {"name":"Chin","price":50,"on":true},
              {"name":"Full Face","price":300,"on":true}
            ]
          },
          {
            "title": "Face Waxing",
            "note": "",
            "items": [
              {"name":"Eyebrow","price":200,"on":true},
              {"name":"Upper Lips","price":100,"on":true},
              {"name":"Forehead","price":100,"on":true},
              {"name":"Chin","price":100,"on":true},
              {"name":"Full Face","price":600,"on":true}
            ]
          },
          {
            "title": "Cream Waxing",
            "note": "",
            "items": [
              {"name":"Hand & Underarms","price":450,"on":true},
              {"name":"Half Leg","price":450,"on":true},
              {"name":"Full Leg","price":800,"on":true},
              {"name":"Back","price":1000,"on":true},
              {"name":"Stomach","price":800,"on":true},
              {"name":"Full Body","price":3000,"on":true}
            ]
          },
          {
            "title": "Rica Waxing",
            "note": "",
            "items": [
              {"name":"Hand & Underarms","price":750,"on":true},
              {"name":"Half Leg","price":750,"on":true},
              {"name":"Full Leg","price":1200,"on":true},
              {"name":"Back","price":1000,"on":true},
              {"name":"Stomach","price":1200,"on":true},
              {"name":"Full Body","price":4000,"on":true},
              {"name":"Brazilian Waxing","price":3000,"on":true}
            ]
          },
          {
            "title": "Manicure & Pedicure",
            "note": "",
            "items": [
              {"name":"Express Manicure","price":1500,"on":true},
              {"name":"Premium Manicure","price":2500,"on":true},
              {"name":"Express Pedicure","price":1600,"on":true},
              {"name":"Premium Pedicure","price":2600,"on":true}
            ]
          },
          {
            "title": "Nails",
            "note": "Nail art is chargeable.",
            "items": [
              {"name":"Gel Polish","price":600,"on":true},
              {"name":"Semi-Permanent Extension","price":1600,"on":true},
              {"name":"Gel-X Extension","price":1700,"on":true},
              {"name":"Gel Extension","price":2000,"on":true},
              {"name":"Acrylic Extension","price":2000,"on":true},
              {"name":"Removing","price":500,"on":true}
            ]
          },
          {
            "title": "Lashes",
            "note": "",
            "items": [
              {"name":"Classic Extension","price":3500,"on":true},
              {"name":"2D/3D/4D Extension","price":4000,"on":true},
              {"name":"Hybrid Extension","price":4000,"on":true},
              {"name":"Mega Volume Extension","price":5000,"on":true}
            ]
          }
        ]
      }
    ],
    "team": [
      {
        "name": "Aakash Limbachiya",
        "role": "Founder",
        "handle": "@akash_the_hair_influencer",
        "url": "https://www.instagram.com/akash_the_hair_influencer",
        "photo": "akash.PNG"
      },
      {
        "name": "Ankur Nai",
        "role": "Co-Founder",
        "handle": "@raizewithankur",
        "url": "https://instagram.com/raizewithankur",
        "photo": "ankur.PNG"
      },
      {
        "name": "Tejas Gondaliya",
        "role": "Creative & Operations Lead",
        "handle": "@tejasgondaliya001",
        "url": "https://www.instagram.com/tejasgondaliya001",
        "photo": "tejas.jpeg"
      }
    ],
    "settings": {
      "whatsapp": "919638565746",
      "phone": "+91 96385 65746",
      "email": "raizethesalon@gmail.com",
      "address": "Indraprasth Saptak, 132 Feet Ring Rd, nr. AEC Flyover, AEC Char Rasta, Naranpura, Ahmedabad, Gujarat 380013",
      "hours": "Open every day, 10:30 AM to 9:30 PM"
    }
  }
  $seed$::jsonb
)
on conflict (id) do update
set data = excluded.data, updated_at = now()
where site_data.data = '{}'::jsonb;
