import streamlit as st

# Konfigurasi Halaman
st.set_page_config(page_title="Tensi Cinta", page_icon="❤️")

# --- FUNGSI LOGIKA MEDIS ---
def hitung_map(sys, dia):
    return round((sys + 2 * dia) / 3, 2)

def klasifikasi_tensi(sys, dia, is_hamil):
    # Standar AHA/ASA 2025 & Kriteria Klinis Spesifik
    if sys > 180 or dia > 120:
        return "Krisis Hipertensi", "🚨 DARURAT! Segera ke IGD Rumah Sakit terdekat!", "🚨"
    elif sys >= 160 or dia >= 90:
        return "Hipertensi Derajat 2 (High Risk)", "⚠️ Segera ke Puskesmas untuk penanganan dan pengobatan medis rutin.", "⚠️"
    
    # Khusus Ibu Hamil (Waspada Preeklamsia >130/80)
    if is_hamil and (sys >= 130 or dia >= 80):
        return "Hipertensi dalam Kehamilan", "🔔 Perlu evaluasi ketat oleh Dokter Spesialis Kandungan/Bidan.", "🤰"
    
    if sys >= 140 or dia >= 90:
        return "Hipertensi Tahap 2", "Konsultasi dokter untuk evaluasi terapi farmakologi.", "❤️"
    elif 130 <= sys <= 139 or 80 <= dia <= 89:
        return "Hipertensi Tahap 1", "Modifikasi gaya hidup dan pantau rutin.", "🧡"
    elif 120 <= sys <= 129 and dia < 80:
        return "Meningkat (Elevated)", "Perbaiki pola makan dan aktivitas fisik.", "💛"
    else:
        return "Normal", "Tetap pertahankan pola hidup sehat!", "💚"

# --- INTERFACE ---

# 1. Fitur Login Sederhana
if 'logged_in' not in st.session_state:
    st.session_state['logged_in'] = False

if not st.session_state['logged_in']:
    st.title("🔐 Login Tensi Cinta")
    username = st.text_input("Username")
    password = st.text_input("Password", type="password")
    if st.button("Masuk"):
        if username == "KIA" and password == "1234": # Ganti sesuai kebutuhan
            st.session_state['logged_in'] = True
            st.rerun()
        else:
            st.error("Username atau password salah")
else:
    # --- HALAMAN UTAMA SETELAH LOGIN ---
    st.title("❤️ Tensi Cinta")
    st.write("Selamat datang! Mari cek kesehatan tekanan darah hari ini.")
    
    if st.button("Log Out"):
        st.session_state['logged_in'] = False
        st.rerun()

    st.divider()

    # Pertanyaan Status Kehamilan
    is_hamil = st.radio("Apakah pasien sedang dalam kondisi Ibu Hamil?", ("Tidak", "Ya"))
    is_hamil_bool = True if is_hamil == "Ya" else False

    # Input Tekanan Darah
    col1, col2 = st.columns(2)
    with col1:
        sys = st.number_input("Sistolik (mmHg)", min_value=50, max_value=250, value=120)
    with col2:
        dia = st.number_input("Diastolik (mmHg)", min_value=30, max_value=150, value=80)

    # Variabel Tambahan
    gejala_tambahan = []
    info_hamil = ""

    # Logika Khusus Ibu Hamil (>130/80)
    if is_hamil_bool and (sys >= 130 or dia >= 80):
        st.warning("⚠️ Deteksi Hipertensi pada Kehamilan. Mohon lengkapi data berikut:")
        sejak_kapan = st.text_input("Sejak kapan tekanan darah tinggi diketahui? (contoh: usia kehamilan 20 minggu)")
        protein_urea = st.selectbox("Protein Urea:", ("+/- (Tidak Diketahui)", "+ (Positif)", "- (Negatif)"))
        kaki_edema = st.checkbox("Apakah ada kaki bengkak (Edema)?")
        
        info_hamil = f"\n- Riwayat: {sejak_kapan}\n- Protein Urea: {protein_urea}\n- Edema Kaki: {'Ya' if kaki_edema else 'Tidak'}"

    # Logika Krisis Hipertensi (>180/120)
    if sys > 180 or dia > 120:
        st.error("🚨 KRISIS HIPERTENSI DETEKSI! Mohon periksa gejala berikut:")
        if st.checkbox("Apakah ada sakit kepala hebat?"): gejala_tambahan.append("Sakit Kepala")
        if st.checkbox("Apakah ada sakit perut / mual muntah?"): gejala_tambahan.append("Sakit Perut")
        if st.checkbox("Apakah ada gangguan pada kaki (lemas/kesemutan/bengkak)?"): gejala_tambahan.append("Masalah Kaki")

    if st.button("Hitung & Kirim Edukasi"):
        map_val = hitung_map(sys, dia)
        status, saran, emoji = klasifikasi_tensi(sys, dia, is_hamil_bool)
        
        st.divider()
        st.subheader(f"{emoji} Hasil: {status}")
        st.metric("MAP (Mean Arterial Pressure)", f"{map_val} mmHg")
        st.info(f"**Edukasi:** {saran}")

        # Menyusun Pesan WhatsApp
        gejala_str = ", ".join(gejala_tambahan) if gejala_tambahan else "Tidak ada"
        pesan_wa = (
            f"*LAPORAN TENSI CINTA*\n"
            f"--------------------------\n"
            f"Status: {'Ibu Hamil' if is_hamil_bool else 'Umum'}\n"
            f"Tekanan Darah: {sys}/{dia} mmHg\n"
            f"MAP: {map_val} mmHg\n"
            f"Kategori: {status}\n"
            f"Gejala: {gejala_str}"
            f"{info_hamil}\n\n"
            f"*Saran:* {saran}"
        )
        
        wa_link = f"https://wa.me/?text={pesan_wa.replace(' ', '%20').replace('', '')}"
        st.link_button("📲 Kirim Hasil ke WhatsApp", wa_link)
