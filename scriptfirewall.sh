
#!/bin/bash
# Script feito por: Luiz Garbin
# Importante editar o arquivo /etc/sudoers
# digite visudo em um terminal e insira as seguintes linhas sem estarem comentadas
#
#
#	%fadmin  ALL=NOPASSWD: /bin/iptables, \
#	                       /usr/bin/useradd, \
#	                       /usr/bin/usermod
#	%ufirewall ALL=NOPASSWD: /bin/iptables
#  
#	lembre-se de criar os grupos ufirewall e fadmin (ex: groupadd fadmin)
#   
#   chmod 751 scriptfirewall
#   chmod 771 scriptfirewall
#
novofirewall(){
clear
echo "sudo iptables -F" > firewall.config ## Salva no arquivo firewall.config a regra do iptables que remove suas regras atuais
echo "sudo iptables -X" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que remove as regras do usuario
echo "sudo iptables -P INPUT DROP" >> firewall.config
## Salva no arquivo firewall.config a regra do iptables que bloqueia todas as entradas
echo "sudo iptables -P FORWARD DROP" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que bloqueia os redirecionamentos
echo "sudo iptables -P OUTPUT DROP" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que bloqueia a saida de pacotes
echo "sudo iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que torna o firewall statefull
echo "sudo iptables -A INPUT -m limit --limit 1/s --limit-burst 4 -j ACCEPT LOG --log-prefix="L DOS" --log-level=info" >> firewall.config
echo "sudo iptables -A In_RULE_0 -j LOG --log-level-info --log-prefix "RULE_0 -- Bloqueada" " >> firewall.config
echo "sudo iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j LOG --log-prefix="BSMURF" --log-level=info" >> firewall.config
echo "sudo iptables -A INPUT -i lo -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera o loopback
echo "sudo iptables -A OUTPUT -o lo -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera o loopback
echo "sudo iptables -A OUTPUT -p icmp -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera a saida do PING
echo "sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera o SSH
echo "sudo iptables -A INPUT -p icmp -s 192.168.0.0/16 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que permite a entrada do PING da rede local
echo "sudo iptables -A INPUT -p icmp -s 10.0.0.0/8 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que permite a entrada do PING da rede local
echo "sudo iptables -A INPUT -p icmp -s 172.16.0.0/12 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que permite a entrada do PING da rede local
echo "sudo iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j ACCEPT" >> firewall.config
## salva a regra de bloqueio do smurf attack no arquivo firewall.config
echo "sudo iptables -A INPUT -m limit --limit 1/s --limit-burst 4 -j ACCEPT" >> firewall.config ## salva a regra de bloqueio do smurf attack no arquivo firewall.config
echo "sudo iptables -N In_RULE_0" >> firewall.config
echo "sudo iptables -A INPUT -s 192.168.2.1 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A INPUT -s 192.168.1.1 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A INPUT -s 192.168.1.0/24 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A FORWARD -s 192.168.2.1 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A FORWARD -s 192.168.1.1 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A FORWARD -s 192.168.1.0/24 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A In_RULE_0 -j DROP" >> firewall.config ## Salva no arquivo firewall.config a regra que bloqueia o spoofing
./firewall.config
echo "Novo firewall criado com sucesso"
}
firewallconfig(){ ## Inicia a subrotina que mostra as regras atuais do iptables
clear
echo
sudo iptables -L ## Mostra as regras atuais do iptables
echo
echo "pressione enter para voltar"
read ans
firewall
}
liberatudo(){
echo "$USER liberou firewall em `date`" >> file.log
sudo iptables -F ## remove as regras atuais do iptables
sudo iptables -X ## remove as regras de usuario do iptables
sudo iptables -P INPUT ACCEPT ##
sudo iptables -P FORWARD ACCEPT ## Aceita todas as conexões ao pc.
sudo iptables -P OUTPUT ACCEPT ##
echo "Firewall liberado"
read tmp
}
ligafirewall(){
echo "$USER ativou firewall em `date`" >> file.log
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
echo "Firewall Ativado"
read tmp
}
ldfirewall(){
clear
echo "pressione:"
echo "1 para desabilitar completamente o firewall"
echo "2 para ativar o firewall"
read ans
case $ans in
1) liberatudo;; ## libera todo o firewall
2) ligafirewall;; ## liga o firewall com as regras predefinidas
*) echo "opção invalida" ; ldfirewall ;; ## informa opção invalida e volta para o menu
esac
}
aplicassh(){
echo "sudo iptables -A INPUT -p tcp --dport 22 -j DROP" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que bloqueia o SSH
sed "s/sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT//g" firewall.config > firewall.config.temp ## Remove do arquivo firewall.config a regra do iptables que permite o SSH e salva em outro arquivo
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sudo iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix="B SSH" --log-level=info ## loga a entrada da regra no sistema
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
echo "Regra Aplicada"
sleep 5
}
bssh(){
clear
echo "Bloqueando SSH aguarde 3 minutos para confirmar a não queda de conexão"
sudo iptables -A INPUT -p tcp --dport 22 -j DROP ## adiciona a regra ao iptables como teste
sleep 180 ## aguarda 3 minutos
./firewall.config ## volta a configuração anterior do firewall.
echo "A regra foi criada por 3 minutos, a conexão foi perdida neste meio tempo?"
echo "Digite:"
echo "1 para aplicar a regra permanentemente"
echo "2 para abortar a regra e voltar para o menu"
ans=0
read ans
case $ans in
1) aplicassh; firewall;; ## executa rotina que ativa a regra
2) firewall;; ## aborta a nova regra para que ela seja revista
*)echo "opção invalida" ; bssh ;;
esac
}
lssh(){
echo "sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT" >> firewall.config ## Salva no arquivo
firewall.config a regra do iptables que libera o SSH
sed "s/sudo iptables -A INPUT -p tcp --dport 22 -j DROP//g" firewall.config > firewall.config.temp ## remove do arquivo firewall.config a regra do iptables que bloqueia o SSH
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sudo iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix="L SSH" --log-level=info ## loga a entrada da
regra no sistema
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
}
ldssh(){
clear
echo "pressione:"
echo "1 para bloquear o SSH"
echo "2 para permitir o SSH"
read ans
case $ans in
1) bssh;; ## bloqueia o SSH
2) lssh;; ## libera o SSH
*) echo "opção invalida" ; ldssh ;; ## informa opção invalida e volta para o menu
esac
}
aplicadns(){
echo "sudo iptables -A OUTPUT -p udp --dport 53 -j DROP" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que bloqueia o DNS
sed "s/sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT//g" firewall.config > firewall.config.temp ## Remove do arquivo firewall.config a regra do iptables que permite o DNS e salva em outro arquivo
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sudo iptables -A OUTPUT -p udp --dport 53 -j LOG --log-prefix="B DNS" --log-level=info ## loga a entrada da regra no sistema
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
echo "Regra Aplicada"
sleep 5
}
bdns(){
clear
echo "Bloqueando DNS aguarde 3 minutos para confirmar a não queda de conexão"
sudo iptables -A OUTPUT -p udp --dport 53 -j DROP ## adiciona a regra ao iptables como teste
sleep 180 ## aguarda 3 minutos
./firewall.config ## volta a configuração anterior do firewall.
echo "A regra foi criada por 3 minutos, a conexão foi perdida neste meio tempo?"
echo "Digite:"
echo "1 para aplicar a regra permanentemente"
echo "2 para abortar a regra e voltar para o menu"
ans=0
read ans
case $ans in
1) aplicadns; firewall;; ## executa rotina que ativa a regra
2) firewall;; ## aborta a nova regra para que ela seja revista
*) echo "opção invalida" ; bdns ;;
esac
}
ldns(){
echo "sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT" >> firewall.config ## Salva no arquivo
firewall.config a regra do iptables que libera o DNS
sed "s/sudo iptables -A OUTPUT -p udp --dport 53 -j DROP//g" firewall.config > firewall.config.temp ## remove do arquivo firewall.config a regra do iptables que bloqueia o SSH
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sudo iptables -A OUTPUT -p udp --dport 53 -j LOG --log-prefix="L DNS" --log-level=info ## loga a entrada da regra no sistema
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
}
lddns(){
echo "pressione:"
echo "1 para bloquear o DNS"
echo "2 para permitir o DNS"
read ans
case $ans in
1) bdns;; ## bloqueia o DNS
2) ldns;; ## libera o DNS
*) echo "opção invalida" ; lddns ;; ## informa opção invalida e volta para o menu
esac
}
aplicahttp(){
echo "sudo iptables -A OUTPUT -p tcp --dport 80 -j DROP" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que bloqueia o HTTP
echo "sudo iptables -A OUTPUT -p tcp --dport 443 -j DROP" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que bloqueia o HTTPS
sed "s/sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT//g" firewall.config > firewall.config.temp ## Remove do arquivo firewall.config a regra do iptables que permite o HTTPS e salva em outro arquivo
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sed "s/sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT//g" firewall.config > firewall.config.temp ## Remove do arquivo firewall.config a regra do iptables que permite o HTTP e salva em outro arquivo
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sudo iptables -A OUTPUT -p tcp --dport 443 -j LOG --log-prefix="B HTTPS" --log-level=info ## loga a entrada da regra no sistema
sudo iptables -A OUTPUT -p tcp --dport 80 -j LOG --log-prefix="B HTTP" --log-level=info ## loga a entrada da regra no sistema
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
echo "Regra Aplicada"
sleep 5
}
bhttp(){
clear
echo "Bloqueando HTTP aguarde 3 minutos para confirmar a não queda de conexão"
sudo iptables -A OUTPUT -p tcp --dport 80 -j DROP ## adiciona a regra ao iptables como teste
sudo iptables -A OUTPUT -p tcp --dport 443 -j DROP ## adiciona a regra ao iptables como teste
sleep 180 ## aguarda 3 minutos
./firewall.config ## volta a configuração anterior do firewall.
echo "A regra foi criada por 3 minutos, a conexão foi perdida neste meio tempo?"
echo "Digite:"
echo "1 para aplicar a regra permanentemente"
echo "2 para abortar a regra e voltar para o menu"
ans=0
read ans
case $ans in
1) aplicahttp; firewall;; ## executa rotina que ativa a regra
2) firewall;; ## aborta a nova regra para que ela seja revista
*) echo "opção invalida" ; bhttp ;;
esac
}
lhttp(){
echo "sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera o http
echo "sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera o https
sed "s/sudo iptables -A OUTPUT -p tcp --dport 443 -j DROP//g" firewall.config > firewall.config.temp ## remove do arquivo firewall.config a regra do iptables que libera o http
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sed "s/sudo iptables -A OUTPUT -p tcp --dport 80 -j DROP//g" firewall.config > firewall.config.temp # remove do arquivo firewall.config a regra do iptables que libera o http
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sudo iptables -A OUTPUT -p tcp --dport 443 -j LOG --log-prefix="L HTTPS" --log-level=info ## loga a entrada da regra no sistema
sudo iptables -A OUTPUT -p tcp --dport 80 -j LOG --log-prefix="L HTTP" --log-level=info ## loga a entrada da regra no sistema
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
}
ldhttp(){
echo "pressione:"
echo "1 para bloquear o HTTP(S)"
echo "2 para permitir o HTTP(S)"
read ans
case $ans in
1) bhttp;; ## bloqueia o HTTP(S)
2) lhttp;; ## libera o HTTP(S)
*) echo "opção invalida" ; ldhttp ;; ## informa opção invalida e volta para o menu
esac
}
portas(){ ## inicia a subrotina que define porta de saida para regras customizadas
echo "digite o numero da porta"
read ans
ps="--sport $ans"
pos="1"
}
portae(){ ## inicia a subrotina que define porta de entrada para regras customizadas
echo "digite o numero da porta"
read ans
pd="--dport $ans"
pod="1"
}
ipo(){ ## inicia a subrotina que define ip de origem para regras customizadas
echo "digite o IP de origem"
read ans
io="-s $ans"
ipor="1"
}
ipd(){ ## inicia a subrotina que define ip de destino para regras customizadas
echo "digite o IP de destino"
read ans
id="-d $ans"
ipde="1"
}
aplicaregra(){
echo "$regra" >> firewall.config ## Salva regra customizada no arquivo firewall.config
$lregra ## Loga regra customizada no arquivo firewall.config
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
echo "Regra Aplicada"
sleep 5
}
fimregra(){ ## inicia regra que verifica quais opcões foram selecionadas para gerar a regra e o log.
# o comando da regra é gravado na variavel regra e o log da regra -e gravado no lregra
if [ "$pos" = "0" ] && [ "$pod" = "0" ] && [ "$ipor" = "0" ] && [ "$ipde" = "0" ]; then
echo "digite ao menos uma opção"
novaregrai
fi
if [ "$pos" = "1" ] && [ "$pod" = "1" ] && [ "$ipor" = "1" ] && [ "$ipde" = "1" ]; then
regra="sudo iptables $dire $proto $ps $pd $io $id $final"
lregra="sudo iptables $dire $proto $ps $pd $io $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "1" ] && [ "$pod" = "1" ] && [ "$ipor" = "1" ] && [ "$ipde" = "0" ]; then
regra="sudo iptables $dire $proto $ps $pd $io $final"
lregra="sudo iptables $dire $proto $ps $pd $io -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "1" ] && [ "$pod" = "1" ] && [ "$ipor" = "0" ] && [ "$ipde" = "1" ]; then
regra="sudo iptables $dire $proto $ps $pd $id $final"
lregra="sudo iptables $dire $proto $ps $pd $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "1" ] && [ "$pod" = "1" ] && [ "$ipor" = "0" ] && [ "$ipde" = "0" ]; then
regra="sudo iptables $dire $proto $ps $pd $final"
lregra="sudo iptables $dire $proto $ps $pd -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "1" ] && [ "$pod" = "0" ] && [ "$ipor" = "1" ] && [ "$ipde" = "1" ]; then
regra="sudo iptables $dire $proto $ps $io $id $final"
lregra="sudo iptables $dire $proto $ps $io $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "1" ] && [ "$pod" = "0" ] && [ "$ipor" = "1" ] && [ "$ipde" = "0" ]; then
regra="sudo iptables $dire $proto $ps $io $final"
lregra="sudo iptables $dire $proto $ps $io -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "1" ] && [ "$pod" = "0" ] && [ "$ipor" = "0" ] && [ "$ipde" = "1" ]; then
regra="sudo iptables $dire $proto $ps $id $final"
lregra="sudo iptables $dire $proto $ps $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "1" ] && [ "$pod" = "0" ] && [ "$ipor" = "0" ] && [ "$ipde" = "0" ]; then
regra="sudo iptables $dire $proto $ps $final"
lregra="sudo iptables $dire $proto $ps -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "0" ] && [ "$pod" = "1" ] && [ "$ipor" = "1" ] && [ "$ipde" = "1" ]; then
regra="sudo iptables $dire $proto $pd $io $id $final"
lregra="sudo iptables $dire $proto $pd $io $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "0" ] && [ "$pod" = "1" ] && [ "$ipor" = "1" ] && [ "$ipde" = "0" ]; then
regra="sudo iptables $dire $proto $pd $io $final"
lregra="sudo iptables $dire $proto $pd $io -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "0" ] && [ "$pod" = "1" ] && [ "$ipor" = "0" ] && [ "$ipde" = "1" ]; then
regra="iptables $dire $proto $pd $id $final"
lregra="iptables $dire $proto $pd $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "0" ] && [ "$pod" = "1" ] && [ "$ipor" = "0" ] && [ "$ipde" = "0" ]; then
regra="sudo iptables $dire $proto $pd $final"
lregra="sudo iptables $dire $proto $io $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "0" ] && [ "$pod" = "0" ] && [ "$ipor" = "1" ] && [ "$ipde" = "1" ]; then
regra="sudo iptables $dire $proto $io $id $final"
lregra="sudo iptables $dire $proto $io $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "0" ] && [ "$pod" = "0" ] && [ "$ipor" = "1" ] && [ "$ipde" = "0" ]; then
regra="sudo iptables $dire $proto $io $final"
lregra="sudo iptables $dire $proto $io -j LOG --log-prefix="REGRA" --log-level=info"
fi
if [ "$pos" = "0" ] && [ "$pod" = "0" ] && [ "$ipor" = "0" ] && [ "$ipde" = "1" ]; then
regra="sudo iptables $dire $proto $id $final"
lregra="sudo iptables $dire $proto $id -j LOG --log-prefix="REGRA" --log-level=info"
fi
echo "$regra"
nregra
}
nregra(){
$regra ## executa o comando da regra customizada como teste
sleep 180 ## espera 3 minutos
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
echo "A regra foi criada por 3 minutos, a conexão foi perdida neste meio tempo?"
echo "Digite:"
echo "1 para aplicar a regra permanentemente"
echo "2 para abortar a regra e voltar para o menu"
ans=0
read ans
case $ans in
1) aplicaregra; firewall;; ## aplica a regra
2) firewall;; ## volta para o menu
*) echo "opção invalida" ; nregra;;
esac
}
novaregrai(){
echo ## executa a subrotina para definir os complementos do comando iptables da regra customizada
echo "digite:"
echo "1 para definir porta de saida"
echo "2 para definir porta de entrada"
echo "3 para definir IP de origem"
echo "4 para definir IP de destino"
echo "5 para prosseguir"
ans=0
read ans
case $ans in
1)portas; novaregrai;;
2)portae; novaregrai;;
3)ipo; novaregrai;;
4)ipd; novaregrai;;
5)fimregra;;
*)echo "opção invalida";novaregrai;;
esac
}
novaregra(){ ## executa a subrotina para definir os complementos do comando iptables da regra
customizada
pos="0"
pod="0"
ipor="0"
ipde="0"
echo "A nova regra sera de bloqueio ou liberação?"
echo "Digite:"
echo "1 para liberar"
echo "2 para bloquear"
ans=0
read ans
case $ans in
1)final="-j ACCEPT";;
2)final="-j DROP";;
*)echo "tente novamente"; novaregra;;
esac
echo
echo "A nova regra sera de entrada ou saida?"
echo "Digite:"
echo "1 para entrada"
echo "2 para saida"
ans=0
read ans
case $ans in
1)dire="-A INPUT";;
2)dire="-A OUTPUT";;
*)echo "tente novamente"; novaregra;;
esac
echo
echo "Qual protocolo?"
echo "1 TCP"
echo "2 UDP"
ans=0
read ans
case $ans in
1)proto="-p tcp";;
2)proto="-p udp";;
*)echo "tente novamente"; novaregra;;
esac
novaregrai
}
bsmurf(){
echo "sudo iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j ACCEPT" >> firewall.config
## salva a regra de bloqueio do smurf attack no arquivo firewall.config
sudo iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j LOG --log-prefix="B SMURF" --log-level=info ## cria log
./firewall.config ## atualiza o arquivo firewall.config
echo "Ataque via SMURF bloqueado"
}
lsmurf(){
sed "s/sudo iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j ACCEPT//g" firewall.config
> firewall.config.temp ## remove a regra de bloqueio do smurf attack do arquivo firewall.config
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sudo iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j LOG --log-prefix="L SMURF" --log-level=info
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
}
ldsmurf(){
echo "pressione:"
echo "1 para bloquear o SMURF"
echo "2 para permitir o SMURF"
read ans
case $ans in
1) bsmurf;; ## bloqueia o SMURF ATTACK
2) lsmurf;; ## libera o SMURF ATTACK
*) echo "opção invalida" ; ldsmurf ;; ## informa opção invalida e volta para o menu
esac
}
bdos(){
echo "sudo iptables -A INPUT -m limit --limit 1/s --limit-burst 4 -j ACCEPT" >> firewall.config ## salva a regra de bloqueio do smurf attack no arquivo firewall.config
sudo iptables -A INPUT -m limit --limit 1/s --limit-burst 4 -j ACCEPT LOG --log-prefix="B DOS" --log-level=info
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
echo "Ataque via DOS bloqueado"
}
ldos(){
sed "s/sudo iptables -A INPUT -m limit --limit 1/s --limit-burst 4 -j ACCEPT//g" firewall.config > firewall.config.temp ## remove a regra de bloqueio do DOS do arquivo firewall.config
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
sudo iptables -A INPUT -m limit --limit 1/s --limit-burst 4 -j ACCEPT LOG --log-prefix="L DOS" --log-level=info
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
}
lddos(){
echo "pressione:"
echo "1 para bloquear o DOS"
echo "2 para permitir o DOS"
read ans
case $ans in
1) bdos;; ## bloqueia o DOS ATTACK
2) ldos;; ## libera o DOS ATTACK
*) echo "opção invalida" ; lddos ;; ## informa opção invalida e volta para o menu
esac
}
aplicaarp(){
sudo iptables -A In_RULE_0 -j LOG --log-level-info --log-prefix "RULE_0 -- Bloqueada" ## loga o bloqueio da regra de spoof
echo "sudo iptables -A In_RULE_0 -j DROP" >> firewall.config ## Salva no arquivo firewall.config a regra que bloqueia o ARP
sed "s/sudo iptables -A In_RULE_0 -j ACCEPT//g" firewall.config > firewall.config.temp ## Remove do arquivo firewall.config a regra que permite o spoofing
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
echo "Regra Aplicada"
sleep 5
}
barp(){
sudo iptables -A In_RULE_0 -j DROP ## Bloqueia o spoof na rede
sleep 180 ## aguarda 3 minutos
./firewall.config ## Retorna o estado anterior do firewall
echo "A regra foi criada por 3 minutos, a conexão foi perdida neste meio tempo?"
echo "Digite:"
echo "1 para aplicar a regra permanentemente"
echo "2 para abortar a regra e voltar para o menu"
ans=0
read ans
case $ans in
1) aplicaarp; firewall;; ## executa rotina que ativa a regra
2) firewall;; ## aborta a nova regra para que ela seja revista
esac
}
larp(){
sudo iptables -A In_RULE_0 -j LOG --log-level-info --log-prefix "RULE_0 -- LIBERADA" ## loga a liberação
da regra do spoof
echo "sudo iptables -A In_RULE_0 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra que libera o spoofing
sed "s/sudo iptables -A In_RULE_0 -j DROP//g" firewall.config > firewall.config.temp ## remove do arquivo firewall.config a regra do spoofing
mv firewall.config.temp firewall.config ## atualiza o arquivo firewall.config
./firewall.config ## Executa um "commit" das regras salvas no arquivo firewall.config
}
ldarp(){
echo "pressione:"
echo "1 para bloquear o Spoofing"
echo "2 para permitir o Spoofing"
read ans
case $ans in
1) barp;; ## bloqueia spoofing
2) larp;; ## libera spoofing
*) echo "opção invalida" ; ldarp ;; ## informa opção invalida e volta para o menu
esac
}
menup(){
clear
echo "**** Script para gerenciamento de usuário e firewall ****"
echo "Bem-Vindo $USER"
echo
echo "O que gostaria de fazer?"
echo "1 - Gerenciar Usuários de Firewall"
echo "2 - Gerenciar Configurações de Firewall"
echo "3 - Sair"
echo "Tecle o digito correspondente a opção desejada:"
read ans
case $ans in
1)menuu ;;
2)menuf ;;
3)exit ;;
*)echo "tente novamente digitar entre as opções fornecidas"; sleep 10 ; menup;;
esac
}
lusuario(){
clear
echo "***** Listagem de usuários *****"
grep 1[0-9][0-9][0-9] /etc/passwd | cut -d ":" -f1,3,5,6 #grep para extrair usuários com id maiores que 1000 do arquivo /etc/passwd combinado com o cut para mostrar somente as colunas de nome, id, grupoe diretorio home.
echo "Pressione entre para voltar ao menu."
read tmp #esperar enter antes de retornar para o menu
menuu
}
check(){
echo "$name" | grep -i "a">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "b">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "c">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "d">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "e">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "f">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "g">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "h">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "i">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "i">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "j">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "k">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "l">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "m">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "n">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "o">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "p">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "q">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "r">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "s">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "t">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "u">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "v">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "w">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "y">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "x">/dev/null
if [ $? != "0" ];then
echo "$name" | grep -i "z">/dev/null
if [ $? != "0" ];then
echo "Favor digitar um nome de usuario com ao menos uma letra"
criar
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
fi
}
criar(){ ## Inicio da subrotina de criar usuario
echo
echo "Digite nome do usuario que deseja criar"
read name ## recebimento do valor do nome do usuario para a criação
check
cut -f1 -d: /etc/passwd | grep -wi $name>/dev/null ## separando o /etc/passwd pelos ":" | procurando o nome do usuario neste arquivo e direcionando para /dev/null
if [ $? = "0" ];then ## verificando se o comando anterior deu erro.
echo "### ERRO usuario especificado ja existe ###"
echo
criar
else
## como deu erro o comando acima pois não foi jogado nada em /dev/null o usuario sera criado
sudo useradd -m $name -c "Firewall" -s /bin/bash ## usuario é criado adicionando comentario e shell
usermod -g ufirewall $name
echo "$name criado com sucesso"
echo "$USER criou $name em `date`" >> file.log ## entrada das informações de criação para o log
sudo passwd "$name"
echo "pressione enter para prosseguir"
read tmp ## Variavel temporaria apenas para aguardar o enter do usuario
clear
menuu
fi
}
senhau(){
clear
echo
echo "Digite nome do usuario que deseja modificar"
read name ## recebimento do valor do nome do usuario para a criação
if [ $name = "root" ];then ## não permitir que o root seja alterado
echo "não é possivel alterar o root"
sleep 10
senhau
fi
cut -f1 -d: /etc/passwd | grep -wi $name > /dev/null ## separando o /etc/passwd pelos ":" | procurando o nome do usuario neste arquivo e direcionando para /dev/null
if [ $? = "0" ];then ## como o comando acima não deu erro, usuario ja existe
sudo passwd "$name" ## criação de um novo password
else
echo "usuario não existe no sistema"
sleep 10
senhau
fi
}
blu(){
clear
echo
echo "Digite nome do usuario que deseja modificar"
read name ## recebimento do valor do nome do usuario para a criação
if [ $name = "root" ];then ## não permitir que o root seja alterado
echo "não é possivel modificar o root"
sleep 10
blu
fi
cut -f1 -d: /etc/passwd | grep -wi $name > /dev/null ## separando o /etc/passwd pelos ":" | procurando o nome do usuario neste arquivo e direcionando para /dev/null
if [ $? = "0" ];then ## como o comando acima não deu erro, usuario ja existe
echo "Digite:"
echo "1 Bloquear usuario "
echo "2 Desbloquear usuario"
echo "3 Menu"
read ans
case $ans in
1)sudo passwd -l $name;echo "usuario bloqueado com sucesso";sleep 5; menuu;;
2)sudo passwd -u $name;echo "usuario desbloqueado com sucesso";sleep 5; menuu;;
3)menuu;;
*)echo "tente novamente"; sleep 5; blu;;
esac
else
echo "usuario não existe no sistema"
sleep 10
blu
fi
}
excluir(){
while [ -z $nome_usuario ] #força entrada no loop do while. -z verifica se a váriavel é nula (vazia)
do
clear
echo "Digite o nome do usuario a ser excluido:"
read nome_usuario
userdel $nome_usuario #deleta o usuário.
echo "Usuário deletado com sucesso!" ; sleep 3
done
}
trgru(){
clear
echo
echo "Digite nome do usuario que deseja modificar"
read name ## recebimento do valor do nome do usuario para a criação
if [ $name = "root" ];then ## não permitir que o root seja alterado
echo "não é possivel modificar o root"
sleep 10
trgru
fi
cut -f1 -d: /etc/passwd | grep -wi $name > /dev/null ## separando o /etc/passwd pelos ":" | procurando o nome do usuario neste arquivo e direcionando para /dev/null
if [ $? = "0" ];then ## como o comando acima não deu erro, usuario ja existe
echo "Digite:"
echo "1 Para $name se tornar administrador do Firewall "
echo "2 Para $name se tornar usuario do Firewall "
echo "3 Menu"
read ans
case $ans in
1)usermod -g fadmin $name ;echo "usuario se tornou administrador do firewall";sleep 5; menuu;;
2)usermod -g ufirewall $name ;echo "usuario se tornou usuario do firewall";sleep 5; menuu;;
3)menuu;;
*)echo "tente novamente"; sleep 5; trgru;;
esac
else
echo "usuario não existe no sistema"
sleep 10
blu
fi
}
menuu(){
clear
echo "Gerenciamento de usuários de firewall"
echo "O que deseja fazer?"
echo "1) Listar usuários."
echo "2) Criar novo usuário."
echo "3) Alterar senha de usuário."
echo "4) Bloquear/Desbloquear usuário."
echo "5) Deletar usuário."
echo "6) Adicionar usuário a um grupo"
echo "7) Retornar ao menu principal"
echo "8) Encerrar script"
echo "Tecle o digito correspondente a opção desejada:"
read ans ## recebe a opção do usuario do que deve fazer
case $ans in
1)clear; lusuario;; ## lista os usuarios
2)clear; criar; menuu ;; ## inicia subrotina de criar usuario
3)clear; senhau; menuu ;; ## inicia subrotina de trocar senha de usuario
4)clear; blu; menuu ;; ## inicia subrotina de editar e volta para o menu
5)clear; excluir; menuu ;; ## inicia subrotina de exlusão
6)clear; trgru; menuu ;;
7) menup ;;
8) exit ;; ## sai do script
*)echo "tente novamente digitar entre as opções fornecidas"; sleep 10 ; menuf;;
esac
}
menuf(){
clear
echo "Gerenciamento de configurações do firewall"
echo "O que deseja fazer?"
echo "0 para verificar as configurações atuais do firewall"
echo "1 para ligar/desligar completamente o firewall"
echo "2 para criar um novo firewall"
echo "3 para liberar/desabilitar SSH"
echo "4 para liberar/desabilitar DNS"
echo "5 para liberar/desabilitar HTTP(S)"
echo "6 para criar regra nova"
echo "7 para ligar/desligar proteção DoS"
echo "8 para ligar/desligar proteção SMURF Attack"
echo "9 para ligar/desligar proteção ARP Spoofing"
echo "10 Visualisar rotas."
echo "11 Visualisar interfaces de rede."
echo "12 Visualização de estatistica de rede."
echo "13 Visualizar status da rede."
echo "14 Retornar ao menu principal"
echo "15 Encerrar script"
echo "Tecle o digito correspondente a opção desejada:"
read ans ## recebe a opção do usuario do que deve fazer
case $ans in
0)clear; firewallconfig;menuf;; ## inicia subrotina de verificar regras atuais
1)clear; ldfirewall ;menuf;; ## inicia subrotina de ligar ou desligar o firewall
2)clear; novofirewall; menuf;;
3)clear; ldssh; menuf;; ## inicia subrotina de ligar ou desligar o SSH
4)clear; lddns; menuf;; ## inicia subrotina de ligar ou desligar o DNS
5)clear; ldhttp; menuf;; ## inicia subrotina de ligar ou desligar o HTTP(s)
6)clear; novaregra ;; ## inicia a subrotina de criar regra customizada
7)clear; lddos; menuf;; ## inicia subrotina de ligar ou desligar a proteção contra dos
8)clear; ldsmurf; menuf;; ## inicia subrotina de ligar ou desligar a proteção contra SMURF
9)clear; ldarp; menuf;; ## inicia subrotina de ligar ou desligar a proteção contra spooging Spoof
10)clear; netstat -r; read ans; menuf;; ## mostra as rotas
11)clear; netstat -i; read ans; menuf;; ## mostra as interfaçes de rede
12)clear; netstat -s | more ; read ans; menuf;; ## mostra as estatisticas da rede
13)clear; ifconfig | more ; read ans; menuf;; ## mostra o status da rede
14) menup;; ## volta para o menu inicial
15) exit ;; # sai do script
*)echo "tente novamente digitar entre as opções fornecidas"; sleep 10 ; menuf;;
esac
}
groupadd -f fadmin
groupadd -f ufirewall
touch firewall.config
chmod 771 firewall.config
c=$(grep -c iptables firewall.config)
clear
if [ $c -gt 20 ]; then
./firewall.config
menup
else
echo "sudo iptables -F" > firewall.config ## Salva no arquivo firewall.config a regra do iptables que remove suas regras atuais
echo "sudo iptables -X" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que remove as regras do usuario
echo "sudo iptables -P INPUT DROP" >> firewall.config
## Salva no arquivo firewall.config a regra do iptables que bloqueia todas as entradas
echo "sudo iptables -P FORWARD DROP" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que bloqueia os redirecionamentos
echo "sudo iptables -P OUTPUT DROP" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que bloqueia a saida de pacotes
echo "sudo iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que torna o firewall statefull
echo "sudo iptables -A INPUT -m limit --limit 1/s --limit-burst 4 -j ACCEPT LOG --log-prefix="L DOS" --log-level=info" >> firewall.config
echo "sudo iptables -A In_RULE_0 -j LOG --log-level-info --log-prefix "RULE_0 -- Bloqueada" " >>firewall.config
echo "sudo iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j LOG --log-prefix="BSMURF" --log-level=info" >> firewall.config
echo "sudo iptables -A INPUT -i lo -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera o loopback
echo "sudo iptables -A OUTPUT -o lo -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera o loopback5
echo "sudo iptables -A OUTPUT -p icmp -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera a saida do PING
echo "sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que libera o SSH
echo "sudo iptables -A INPUT -p icmp -s 192.168.0.0/16 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que permite a entrada do PING da rede local
echo "sudo iptables -A INPUT -p icmp -s 10.0.0.0/8 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que permite a entrada do PING da rede local
echo "sudo iptables -A INPUT -p icmp -s 172.16.0.0/12 -j ACCEPT" >> firewall.config ## Salva no arquivo firewall.config a regra do iptables que permite a entrada do PING da rede local
echo "sudo iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j ACCEPT" >> firewall.config ## salva a regra de bloqueio do smurf attack no arquivo firewall.config
echo "sudo iptables -A INPUT -m limit --limit 1/s --limit-burst 4 -j ACCEPT" >> firewall.config ## salva a regra de bloqueio do smurf attack no arquivo firewall.config
echo "sudo iptables -N In_RULE_0" >> firewall.config
echo "sudo iptables -A INPUT -s 192.168.2.1 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A INPUT -s 192.168.1.1 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A INPUT -s 192.168.1.0/24 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A FORWARD -s 192.168.2.1 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A FORWARD -s 192.168.1.1 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A FORWARD -s 192.168.1.0/24 -j In_RULE_0" >> firewall.config
echo "sudo iptables -A In_RULE_0 -j DROP" >> firewall.config ## Salva no arquivo firewall.config a regra que bloqueia o spoofing
./firewall.config
menup
fi
