#!/bin/bash
# author: Anderson Morais
# date: 17-may-2021(reeditado)
# version: 4
set -e
declare -gr USER=$(whoami)
# ROOT=$EUID
declare -gi TP=286
declare -gi PRO=19283
declare -g SH=""
declare -g SYSMSG=""
declare -grA SN=(["s"]="SIM" ["n"]="NÃO")
declare -gra PROGS=("VLC" "Firefox" "Chrome")
declare -gra TMP=(30 $((30*60)) $((60*60)) $((90*60)) $((120*60)))

if test "${USER}" = root; then
  	declare -gr USERMSG="# Usuário '${USER}' - root previlégios"
else
  	declare -gr USERMSG="$ Usuário '${USER}' - non root"
fi

function LimpaVar() {
	TP=-3293
	PRO=-17226
	SH=""
	SYSMSG=""
}

function Top() {
	local top=""
  	local USERMSGLEN=${#USERMSG}
  	local SYSMSGLEN=${#SYSMSG}
  	local SPACES=""

  	top="+=================================================+\n"
  	top+="|   ---Programa Desliga - ANDERSON MORAIS---      |\n"

  	if test -n "$USERMSGLEN"; then
    	top+="| ${USERMSG}$(printf "%$((48-${USERMSGLEN}))s")|\n"
  	fi

  	if test -n "$SYSMSGLEN"; then
    	top+="| ${SYSMSG}$(printf "%$((48-${SYSMSGLEN}))s")|\n"
  	fi
  	top+="+-------------------------------------------------+"

  	echo -e "${top}"
}

function Tempo() {
  	#### enquanto o conteudo da var TP (cada caracter - cada posicao da string) 
  	#### nao estiver entre 0 e 9 continua perguntando 
  	#TP=""
  	local menu=""

  	until echo "${TP}" | grep -E '^[0-5].{0}$'; do
	    menu="+-------------------------------------------------+\n"
	    menu+="| - - Tempo para fechar o programa: $(printf "%13s") |\n"
	    menu+="| - - - - - - - - - - - - - - - - - - - - - - - - |\n"
	    menu+="| - - [1]  30 segundos $(printf "%26s") |\n"
	    menu+="| - - [2]  30 minutos $(printf "%27s") |\n"   
	    menu+="| - - [3]  60 minutos $(printf "%27s") |\n"
	    menu+="| - - [4]  90 minutos $(printf "%27s") |\n"
	    menu+="| - - [5] 120 minutos $(printf "%27s") |\n"
	    menu+="| - - - - - - - - - - - - - - - - - - - - - - - - |\n"
	    menu+="| - - [0] Sair $(printf "%34s") |\n"
	    menu+="+-------------------------------------------------+"
	    echo -e "${menu}"
	    read -p "| - - :: " TP
  	done

  	if [ "$TP" -ge 1 -a "$TP" -le 5 ]; then
    	TP=$(($TP-1))
  	else
    	Finalizar
    	return
  	fi
  
  	Programa 
}

function Programa() {
	local menu=""

  	until echo "${PRO}" | grep -E '^[0-3].{0}$'; do
	    menu="+-------------------------------------------------+\n"
	    menu+="+ - - Programa que será finalizado: $(printf "%13s") |\n"
	    menu+="+ - - - - - - - - - - - - - - - - - - - - - - - - |\n"
	    menu+="+ - - [1] ${PROGS[0]} $(printf "%35s") |\n"
	    menu+="+ - - [2] ${PROGS[1]} $(printf "%31s") |\n"
	    menu+="+ - - [3] ${PROGS[2]} $(printf "%32s") |\n"
	    menu+="+ - - - - - - - - - - - - - - - - - - - - - - - - |\n"
	    menu+="+ - - [0] Sair $(printf "%34s") |\n"
	    menu+="+-------------------------------------------------+"
	    echo -e "${menu}"
	    read -p "| - - :: " PRO
  	done

  	if [ "$PRO" -ge 1 -a "$PRO" -le 3 ]; then
    	PRO=$(($PRO-1))
  	else
    	Finalizar
    	return
  	fi

  	# -u: upper
  	typeset -l p=${PROGS[${PRO}]}
  	# checa se o programa esta em execucao
	if ! pgrep -x ${p} > /dev/null; then
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

	until echo "${SH}" | grep -E '^[snf].{0}$'; do
	    menu="+-------------------------------------------------+\n"
	    menu+="+ - - Desligar o computador também? (s/n)         |\n"
	    menu+="+ - - (f)inalizar para sair                       |\n"
	    menu+="+-------------------------------------------------+"
	    echo -e "${menu}"
	    read -p "| - - :: " SH
  	done

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
	local ddate=$(date "+%d/%h/%y %H:%M:%S")
	declare -g arrayFooter
	typeset -l p=${PROGS[${PRO}]}

	arrayFooter="| Contagem iniciada em - ${ddate}"
	arrayFooter[1]="| Contagem iniciada em - ${ddate}"
	arrayFooter[2]="| Contagem iniciada em - ${ddate}"
	arrayFooter[3]="| Contagem iniciada em - ${ddate}"
	arrayFooter[4]="| Programa: ${p}"
	arrayFooter[5]="| Programa: ${p}"
	arrayFooter[6]="| Programa: ${p}"
	arrayFooter[7]="| Desligar o computador também? (s/n): ${SN[${SH}]}"
	arrayFooter[8]="| Desligar o computador também? (s/n): ${SN[${SH}]}"
	arrayFooter[9]="| Desligar o computador também? (s/n): ${SN[${SH}]}"
	key=0
}

function FuncaoFoot() {
	echo ${arrayFooter[$key]}
	key=$(($key+1))

	if test "${key}" -eq 10; then  
		key=0
	fi
}

function Cronometro() {	
	local tp=${TMP[${TP}]}
	typeset -l p=${PROGS[${PRO}]}
	DadosFoot

	while [[ "${tp}" -gt 0 ]]; do
	    Top
	    echo -e "+ - - - -\n| - Finalizar o programa ${p} em: ${tp} segundos \n+ - - - -"
	    tp=$((${tp}-1))
	    FuncaoFoot ${array[@]}
	    # echo $RANDOM
	    echo "+ - - - -"
	    sleep 1
	    clear
  	done

	ProgKill
}

function ProgKill() {
	local menu=""
	typeset -l p=${PROGS[${PRO}]}
	Top	

	pkill "${p}" && {
		menu="+------------------------------>\n+\n"
		menu+="| + ${p} -> FINALIZADO\n+\n"
		menu+="+------------------------------>"
	} || {
		menu="+------------------------------>\n+|n"
		menu+="| + ERROR!!!\n+\n"
		menu+="+------------------------------>"
	}
	echo -e "${menu}"
	sleep 2
}

function Shutdown () {
	Top
	Finalizar
	echo "Desligando o computador em 5 segundos..."
	sleep 5
	shutdown -h now
}

function Continuar() {
    local sn=""

    until echo "${sn}" | grep -E '^[sn].{0}$'; do
		echo "| Deseja continuar? (s/n)"
		read -p "| :: " sn
    done

    if test "${sn}" = s; then
    	StartPrograma
    else
    	Finalizar
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
