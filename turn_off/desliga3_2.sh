#!/bin/bash
# author: Anderson Morais
# date: 15-may-2021(reeditado)
# version: 3.2
#
USER=$(whoami)
ROOT=$EUID
#
#
SYSMSG=""
if [ "$USER" == root ]; then
  USERMSG="# Usuário $USER - root previlégios"
else
  USERMSG="$ Usuário $USER - non root"
fi
#
function Top() {
  USERMSGLEN=${#USERMSG}
  SYSMSGLEN=${#SYSMSG}

  echo "+=================================================+"
  echo "|   ---Programa Desliga - ANDERSON MORAIS---      |"

  if [[ "$USERMSGLEN" -gt 0 ]]; then
    SPACES=$(printf "%$((48-${USERMSGLEN}))s")
    echo "| ${USERMSG}${SPACES}|"
  fi

  if [[ "$SYSMSGLEN" -gt 0 ]]; then
    SPACES=$(printf "%$((48-${SYSMSGLEN}))s")
    echo "| ${SYSMSG}${SPACES}|"
  fi
  echo "+-------------------------------------------------+"
}
#
#
function Tempo() {
  #
  #### enquanto o conteudo da var TP (cada caracter - cada posicao da string) 
  #### nao estiver entre 0 e 9 continua perguntando 
  #
  TP=""
  tp=''
  until echo $tp | grep -E '^[0-5].{0}$'; do
    echo "+-------------------------------------------------+"
    echo "| - - Tempo para fechar o programa:               |"
    echo "| - - - - - - - - - - - - - - - - - - - - - - - - |"
    echo "| - - [1]  30 segundos                            |"
    echo "| - - [2]  30 minutos                             |"   
    echo "| - - [3]  60 minutos                             |"
    echo "| - - [4]  90 minutos                             |"
    echo "| - - [5] 120 minutos                             |"
    echo "| - - - - - - - - - - - - - - - - - - - - - - - - |"
    echo "| - - [0] Sair                                    |"
    echo "+-------------------------------------------------+"
    read -p "| - - :: " tp
  done

  if [[ "$tp" -eq 1 ]]; then
    TP=30
  elif [[ "$tp" -eq 2 ]]; then
    TP=$((30*60))
  elif [[ "$tp" -eq 3 ]]; then
    TP=$((60*60))
  elif [[ "$tp" -eq 4 ]]; then
    TP=$((90*60))
  elif [[ "$tp" -eq 5 ]]; then
    TP=$((120*60))
  else
    Finalizar
    return
  fi
  
  Programa 
}
#
#
function Programa() {
  PRO=""
  pro=''
  until echo $pro | grep -E '^[0-3].{0}$'; do
    echo "+-------------------------------------------------+"
    echo "+ - - Programa que será finalizado:               |"
    echo "+ - - - - - - - - - - - - - - - - - - - - - - - - |"
    echo "+ - - [1] VLC                                     |"
    echo "+ - - [2] Firefox                                 |"
    echo "+ - - [3] Chrome                                  |"
    echo "+ - - - - - - - - - - - - - - - - - - - - - - - - |"
    echo "+ - - [0] Sair                                    |"
    echo "+-------------------------------------------------+"
    read -p "| - - :: " pro
  done

  if [[ "$pro" -eq 1 ]]; then
    PRO='vlc'
  elif [[ "$pro" -eq 2 ]]; then
    PRO='firefox'
  elif [[ "$pro" -eq 3 ]]; then
    PRO='chrome'
  else
    Finalizar
    return
  fi

  # checa se o programa esta em execucao
  if ! pgrep -x $PRO > /dev/null; then
    SYSMSG="**O programa ${PRO} não esta em execução"
    StartPrograma
  else
    Pergunta
  fi
}
#
function Pergunta() {
  #
  #### enquanto o conteudo da var SH nao for s ou n 
  #### e tamanho 1 (apenas 1 caracter), continua perguntando
  #
  SH=""
  sh=''
  until echo $sh | grep -E '^[snf].{0}$'; do
    echo "+-------------------------------------------------+"
    echo "+ - - Desligar o computador também? (s/n)         |"
    echo "+ - - (f)inalizar para sair                       |"
    echo "+-------------------------------------------------+"
    read -p "| - - :: " sh
  done

  if [[ "$sh" == f ]]; then
    Finalizar
    return
  else
    SH=${sh}
    Escolha $SH $PRO $TP
  fi
}	
#
#
function Escolha() {
  if [[ "$SH" == s ]]; then
    if [[ "$USER" == root ]]; then	
      clear 
      SH=SIM
      Cronometro $PRO $SH $TP
      Shutdown
    else
      SYSMSG="Comando shutdwon não permitido para o usuário"
      StartPrograma
    fi
  else
    clear
    SH=NÃO
    Cronometro $PRO $SH $TP
    Finalizar
  fi
}
#
#  
function DadosFoot() {
  ddate=$(date "+%d/%h/%y %H:%M:%S")
  array="| Contagem iniciada em - ${ddate}"
  array[1]="| Contagem iniciada em - ${ddate}"
  array[2]="| Contagem iniciada em - ${ddate}"
  array[3]="| Contagem iniciada em - ${ddate}"
  array[4]="| Programa: ${PRO}"
  array[5]="| Programa: ${PRO}"
  array[6]="| Programa: ${PRO}"
  array[7]="| Desligar o computador também? (s/n): ${SH}"
  array[8]="| Desligar o computador também? (s/n): ${SH}"
  array[9]="| Desligar o computador também? (s/n): ${SH}"
  key=0
}
#
# 
function FuncaoFoot() {
  echo ${array[$key]}
  key=$(($key+1))
  if [ "$key" -eq 10 ]; then  
    key=0
  fi
}
#
#
function Cronometro() {
  #gt -> (greather than)maior que, equival ao)
  DadosFoot $TP $PRO $SH $HR
  while [[ "$TP" -gt 0 ]]; do
    Top
    echo -e "+ - - - -\n| - Finalizar o programa "$PRO" em:" $TP "segundos \n+ - - - -"
    TP=$(($TP-1))
    FuncaoFoot ${array[@]}
    # echo $RANDOM
    echo "+ - - - -"
    sleep 1
    clear
  done
  ProgKill $PRO
}
#
#
function ProgKill() {
  Top
  pkill $PRO && {
    echo -e "+------------------------------>\n+"
    echo -e "| + ${PRO} -> FINALIZADO\n+"
    echo "+------------------------------>"
  } || {
    echo -e "+------------------------------>\n+"
    echo -e "| + ERROR!!!\n+"
    echo "+------------------------------>"
  }
  sleep 2
}
#
#
function Shutdown () {
  Top
  Finalizar
  echo "Desligando o computador em 5 segundos..."
  sleep 5
  shutdown -h now
}
#
function Continuar() {
    SN=""
    until echo $SN | grep -E '^[sn].{0}$'; do
      echo "| Deseja continuar? (s/n)"
      read -p "| :: " SN
    done
    if [ "$SN" == s ]; then
      StartPrograma
    else
      Finalizar
    fi      
}
#
#
function StartPrograma() {
  clear
  Top
  Tempo 
}
#
function Finalizar() {
  echo "+-------------------------------------------------+"
  echo "|   ---Finalizando programa Desliga---            |"
  echo -e "|________________TCHAU____________________________|\n"
}
#
function Start() {
  if [ "$USER" == root ]; then
    StartPrograma
  else
    Top
    Continuar
  fi
}
#
###### inicio do programa #########
Start
#
