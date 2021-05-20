#!/bin/bash
# author: Anderson Morais
# date: 19-may-2021(reeditado)
# version: 6
#
resize -s 30 51
clear
# ROOT=$EUID
declare -gr USER=$(whoami)
# tipo global integer
declare -gi TP=$(($RANDOM+$RANDOM))
declare -gi PRO=$(($RANDOM+$RANDOM))
declare -g SH=""
declare -g SYSMSG=""
declare -g processo=""
# tipo global readonly Associative
declare -grA SN=(["s"]="SIM" ["n"]="NÃO")
# tipo global readonly non-associative
declare -gra PROGS=("VLC" "Firefox" "Chrome")
declare -gra TMP=(30 $((30*60)) $((60*60)) $((90*60)) $((120*60)))

if test "${USER}" = root; then
	declare -gr USERMSG="# Usuário '${USER}' - root previlégios"
else
	declare -gr USERMSG="$ Usuário '${USER}' - non root"
fi

function LimpaVar() {
	TP=$(($RANDOM+$RANDOM))
	PRO=$(($RANDOM+$RANDOM))
	SH=""
	SYSMSG=""
}

function Top() {
	local top=""
	local USERMSGLEN=${#USERMSG}
	local SYSMSGLEN=${#SYSMSG}
	local espacos=""

	# lagura menus: 51 colunas
	for i in $(seq 49); do espacos+="=";done
	top="+${espacos}+\n"
	top+="|   ---Programa Desliga - ANDERSON MORAIS---      |\n"

  	if test -n "$USERMSGLEN"; then
		top+="| ${USERMSG}$(printf %$((48-${USERMSGLEN}))s)|\n"
  	fi

  	if test -n "$SYSMSGLEN"; then
    	top+="| ${SYSMSG}$(printf %$((48-${SYSMSGLEN}))s)|\n"
  	fi

  	top+="+${espacos}+"

  	echo -e "${top}"
}

function Tempo() {
  	#### enquanto o conteudo da var TP (cada caracter - cada posicao da string) 
  	#### nao estiver entre 0 e 9 continua perguntando 
  	#TP=""
  	local menu=""
  	local tp=""
  	local espacos=""

  	for i in $(seq 49); do espacos+="-";done
  	menu="+${espacos}+\n"
	menu+="| - - Tempo para fechar o programa: $(printf "%13s") |\n"
	espacos=""
	for i in $(seq 24); do espacos+=" -";done
	menu+="|${espacos} |\n"
	menu+="| - - [1]  30 segundos $(printf "%26s") |\n"
	menu+="| - - [2]  30 minutos $(printf "%27s") |\n"   
	menu+="| - - [3]  60 minutos $(printf "%27s") |\n"
	menu+="| - - [4]  90 minutos $(printf "%27s") |\n"
	menu+="| - - [5] 120 minutos $(printf "%27s") |\n"
	espacos=""
	for i in $(seq 24); do espacos+=" -";done
	menu+="|${espacos} |\n"
	menu+="| - - [0] Sair $(printf "%34s") |\n"
	espacos=""
	for i in $(seq 49); do espacos+="-";done
  	menu+="+${espacos}+"
	echo -e "${menu}"

  	tput sc
  	until echo "${tp}" | grep -E '^[0-5].{0}$'; do
		tput rc; tput el;
		read -p "| - - :: " tp
  	done
  	tput rc; tput ed;

  	if [ "$tp" -ge 1 -a "$tp" -le 5 ]; then
    	TP=$(($tp-1))
  	else
		Finalizar
		return
  	fi
  
  	Programa 
}

function Programa() {
	local menu=""
	local pro=""
	local espacos=""

  	for i in $(seq 49); do espacos+="-";done
  	menu="+${espacos}+\n"
	menu+="+ - - Programa que será finalizado: $(printf "%13s") |\n"
	espacos=""
	for i in $(seq 24); do espacos+=" -";done
	menu+="|${espacos} |\n"
	menu+="| - - [1] ${PROGS[0]} $(printf "%35s") |\n"
	menu+="| - - [2] ${PROGS[1]} $(printf "%31s") |\n"
	menu+="| - - [3] ${PROGS[2]} $(printf "%32s") |\n"
	espacos=""
	for i in $(seq 24); do espacos+=" -";done
	menu+="|${espacos} |\n"
	menu+="| - - [0] Sair $(printf "%34s") |\n"
	espacos=""
	for i in $(seq 49); do espacos+="-";done
  	menu+="+${espacos}+"
	echo -e "${menu}"

	tput sc
  	until echo "${pro}" | grep -E '^[0-3].{0}$'; do
  		tput rc; tput el;
		read -p "| - - :: " pro
  	done
  	tput rc; tput ed;

  	if [ "$pro" -ge 1 -a "$pro" -le 3 ]; then
		PRO=$(($pro-1))
  	else
		Finalizar
		return
  	fi

  	# -u: upper
  	processo=${PROGS[${PRO}],,}
  	# checa se o programa esta em execucao
	if ! pgrep -x ${processo} > /dev/null; then
		p=${PROGS[${PRO}]}
		LimpaVar
		SYSMSG="**O programa ${p} não esta em execução"
		StartPrograma
	else		
		Pergunta
	fi
}

function Pergunta() {
	#### enquanto o conteudo da var SH nao for s ou n 
	#### e tamanho 1 (apenas 1 caracter), continua perguntando
	local menu=""
	local espacos=""

  	for i in $(seq 49); do espacos+="-";done
  	menu="+${espacos}+\n"
	menu+="+ - - Desligar o computador também? (s/n)         |\n"
	menu+="+ - - (f)inalizar para sair                       |\n"
	espacos=""
	for i in $(seq 49); do espacos+="-";done
  	menu+="+${espacos}+"
	echo -e "${menu}"

	tput sc
	until echo "${SH}" | grep -E '^[snf].{0}$'; do
		tput rc; tput el;
		read -p "| - - :: " SH
  	done
  	tput rc; tput ed;

	if test "$SH" = f ; then
		Finalizar
		return
	else
		Escolha
	fi
}	

function Escolha() {
	if test "${SH[s]}" = s; then
		if test "${USER}" = root; then	
			clear
			Cronometro
			Shutdown
		else
			LimpaVar
			SYSMSG="Comando shutdwon não permitido para o usuário"			
			StartPrograma
		fi
	else
		clear
		Cronometro
		Finalizar
	fi
}
 
function DadosFoot() {
	local ddata=$(date "+%d/%h/%y %H:%M:%S")
	local dataend=$(date -d "+${TMP[${TP}]} seconds" "+%d/%h/%y %H:%M:%S")
	declare -g crondados
	local dados
	
	# 22
	dados="| Início da contagem: ${ddata}"
	crondados="${dados} $(printf %$((48-${#dados}))s) |\n"
	# 23
	dados="| Termino da contagem: ${dataend}"
	crondados+="${dados} $(printf %$((48-${#dados}))s) |\n"
	# 25
	dados="| Desligar o computador: ${SN[${SH}]}"
	crondados+="${dados} $(printf %20s) |"
}

function Cronometro() {	
	local tp=${TMP[${TP}]}
	local menu=""
	local dados
	local continue=1
	local espacos=""
	DadosFoot
	Top

	for i in $(seq 24); do espacos+=" -";done
	menu+="|${espacos} |\n"
  	menu+="${crondados}\n"
  	espacos=""
	for i in $(seq 24); do espacos+=" -";done
	menu+="|${espacos} |"
	echo -e "${menu}"
	
	tput sc
	while [[ "${tp}" -gt 0 ]]; do
		tput rc; tput el;
		dados="| Finalizar o programa ${PROGS[${PRO}]} em: ${tp} segundos"
		echo -e "${dados} $(printf %$((48-${#dados}))s) |\n+"

		if [ $(echo ${tp: -1}) -eq 0 ]; then
			if [ $((${tp}%30)) -eq 0 ]; then
				if ! pgrep -x ${processo} > /dev/null; then
					continue=0
					break
				fi
			fi
		fi

		((tp--))		
		sleep 1
  	done
  	tput rc; tput ed;

  	if [ "$continue" -eq 1 ]; then
		ProgKill
	else
		espacos=""
		for i in $(seq 24); do espacos+=" -";done
		menu="|${espacos} |\n"
		dados="| O programa ${PROGS[${PRO}]} não está mais em execução"
		menu+="${dados} $(printf %$((48-${#dados}))s) |\n"
		espacos=""
		for i in $(seq 24); do espacos+=" -";done
		menu+="|${espacos} |"
		echo -e "${menu}"
	fi
}

function ProgKill() {
	local menu=""

	menu="+ - - - - - - - - - - - - - - - - - - - - - - - - +\n"
	menu+="| Resultado: $(printf %36s) |\n"
	pkill "${processo}" && {		
		m="| [x] ${PROGS[${PRO}]} -> FINALIZADO"
		menu+="${m} $(printf %$((48-${#m}))s) |\n"
		m="| [ ] ${PROGS[${PRO}]} -> NÃO FINALIZADO"
		menu+="${m} $(printf %$((48-${#m}))s) |\n"
	} || {
		m="| [ ] ${PROGS[${PRO}]} -> FINALIZADO"
		menu+="${m} $(printf %$((48-${#m}))s) |\n"
		m="| [x] ${PROGS[${PRO}]} -> NÃO FINALIZADO"
		menu+="${m} $(printf %$((48-${#m}))s) |\n"
	}
	menu+="+ - - - - - - - - - - - - - - - - - - - - - - - - +"

	echo -e "${menu}"
}

function Shutdown () {
	Finalizar
	echo "Desligando o computador em 5 segundos..."
	sleep 5
	shutdown -h now
}

function Continuar() {
    local sn=""
    
    echo -e "| Deseja continuar? (s/n)"

    tput sc
    until echo "${sn}" | grep -E '^[sn].{0}$'; do
    	tput rc; tput el;
		read -p "| :: " sn
    done
    tput rc; tput ed;

    if test "${sn}" = s; then
		StartPrograma
    else
		Finalizar
		return
    fi      
}

function StartPrograma() {
	clear
	Top
	Tempo
}

function Finalizar() {
	local footer=""
	footer="+-------------------------------------------------+\n"
	footer+="|   ---Finalizando programa Desliga---            |\n"
	footer+="|________________TCHAU____________________________|\n"
	echo -e "${footer}"
}

function Start() {
	if test "${USER}" = root; then
		StartPrograma
	else
		Top
		Continuar
	fi
}
###### inicio do programa #########
Start
######
