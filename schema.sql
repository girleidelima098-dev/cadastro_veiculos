create table public.veiculos (
  id bigint generated always as identity primary key,
  marca varchar(50) not null,
  modelo varchar(100) not null,
  ano integer not null,
  valor decimal(12,2) not null,
  quilometragem integer not null
);

alter table public.veiculos enable row level security;

create policy "acesso_veiculos" on public.veiculos
  for all using (true) with check (true);

grant usage on schema public to anon;
grant select, insert, update, delete on public.veiculos to anon;