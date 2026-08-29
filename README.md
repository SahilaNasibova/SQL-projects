# Əmək Haqqı və Əlavə İş Saatlarının Hesablanması (Oracle SQL/PLSQL)

Bu layihə iş təqvimi, sektora görə vergi qaydaları və sosial ayırma dərəcələri əsasında xalis əmək haqqını və əlavə iş saatlarına görə ödənişi hesablayan Oracle PL/SQL həllidir.

## 📁 Layihədə Nə Var

### 1. İş Təqvimi (Work Calendar)
2026-cı il üçün doldurulmuş `work_calendar` cədvəli:
- İş günü / həftəsonu işarələri
- Bayram və qeyri-iş günləri
- Qısa (bayram öncəsi) iş günləri
- Hər tarix üzrə gündəlik iş saatları

### 2. Xalis Əmək Haqqı Funksiyası — `calculate_net_salary`
Ümumi əmək haqqından (brutto) xalis əmək haqqını hesablayır:
- **Sektor** (`ozel` – özəl / `dovlet` – dövlət)
- Mütərəqqi gəlir vergisi pilləkanı
- Sosial sığorta, işsizlikdən sığorta, icbari tibbi sığorta
- Könüllü həmkarlar ittifaqı haqqı (union fee)
- Vergi güzəşti (tax relief) çıxılması

### 3. Əlavə İş Saatları Funksiyası — `calculate_overtime_salary`
Verilmiş ay üçün ümumi ödənişi (xalis əmək haqqı + əlavə iş saatları) hesablayır:
- `calculate_net_salary` vasitəsilə xalis əmək haqqını hesablayır
- `work_calendar`-dan aylıq iş saatlarını cəmləyir
- Saatlıq dərəcəni və əlavə iş saatı ödənişini (2 qat) hesablayır

## 🛠 Texnologiya
- Oracle SQL / PL SQL
- Təqvim yaratmaq üçün sequence-lər, funksiyalar, `CONNECT BY`

## ▶️ İstifadə Nümunəsi
```sql
SELECT calculate_overtime_salary(
    11,        -- gün
    3,         -- ay
    2026,      -- il
    10000,     -- brutto əmək haqqı
    5,         -- əlavə iş saatı
    'dovlet',  -- sektor
    0          -- həmkarlar ittifaqı haqqı
) AS total_salary
FROM dual;
```

## 📌 Qeyd
Vergi və ayırma dərəcələri 2026-cı il qaydalarına və skriptdə həyata keçirilən özəl (`ozel`) və dövlət (`dovlet`) sektor məntiqinə əsaslanır. Qanunvericilikdə dəyişiklik olarsa, pilləkan və dərəcələri uyğunlaşdırın.
