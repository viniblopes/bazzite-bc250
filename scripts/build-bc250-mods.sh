#!/bin/bash
set -ou exitecho

# 1. PREPARAÇÃO DO AMBIENTE
KVER=$(ls /usr/lib/modules | head -n 1)
rpm-ostree install kernel-devel kernel-headers gcc make git python3 python3-pip cargo wget curl patch dkms

# ==========================================
# 2. PATCH DO KERNEL (GPU 40 CU Unlock)
# ==========================================
echo "Construindo driver customizado da GPU (40 CUs)..."
git clone https://github.com/duggasco/bc250-40cu-unlock.git /tmp/bc250-unlock
cd /tmp/bc250-unlock

# Engana o script oficial para compilar pro kernel do Bazzite, não da nuvem
sed -i "s/\$(uname -r)/$KVER/g" scripts/bc250-enable-40cu.sh
sed -i "s/\`uname -r\`/$KVER/g" scripts/bc250-enable-40cu.sh

# Roda apenas o BUILD (Gera o arquivo amdgpu.ko)
./scripts/bc250-enable-40cu.sh build

# Faz o "ENABLE" de forma segura para o Bazzite: Copia o driver gerado para a pasta do kernel
mkdir -p /usr/lib/modules/$KVER/extra
find . -name "amdgpu.ko" -type f -exec cp {} /usr/lib/modules/$KVER/extra/ \;

# ==========================================
# 3. GOVERNADOR DA GPU (Usa config.toml)
# ==========================================
echo "Construindo Governador da GPU..."
git clone https://github.com/filippor/cyan-skillfish-governor.git /tmp/cyan-gov
cd /tmp/cyan-gov
cargo build --release
cp target/release/cyan-skillfish-governor /usr/bin/
systemctl enable cyan-skillfish-governor.service

# ==========================================
# 4. GOVERNADOR DA CPU (Usa overclock.conf)
# ==========================================
echo "Instalando SMU OC da CPU..."
git clone https://github.com/bc250-collective/bc250_smu_oc.git /tmp/bc250-smu
cd /tmp/bc250-smu
pip3 install --prefix=/usr --no-cache-dir --break-system-packages .
systemctl enable bc250-cpu-oc.service

# ==========================================
# 5. FINALIZAÇÃO E ATUALIZAÇÃO DA ÁRVORE
# ==========================================
# Isso faz o Bazzite reconhecer o novo amdgpu.ko das 40 CUs e atualizar o sistema interno
depmod -a -b /usr $KVER