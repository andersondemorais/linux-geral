#!/bin/bash
# author: Anderson Morais
# date: 15-may-2021(reeditado)
# version: 2
#
USER=$(whoami)
ROOT=$EUID
#
#
SYSMSG=""
if [ "$USER" == root ]; then
  USERMSG="Usuario $USER - root previlegios"
else
  USERMSG="Usuario $USER - non root"
fi
#
function Top() {
  echo -e "---Programa Desliga - ANDERSON MORAIS---"
  echo -e ${USERMSG}
  echo -e ${SYSMSG}
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
    echo "+---------------------------------------------------------------+"
    echo "+ - - Tempo para fechar o programa: "
    echo "+ - - - - - - - - - - - -"
    echo "+ - - [1] 30 segundos"
    echo "+ - - [2] 30 minutos"
    echo "+ - - [3] 60 minutos"
    echo "+ - - [4] 90 minutos"
    echo "+ - - [5] 120 minutos"
    echo "+ - - - - - - - - - - - -"
    echo "+ - - [0] Sair"
    read -p "+ - - :: " tp
  done

  if [[ tp -eq 1 ]]; then
    TP=30
  elif [[ tp -eq 2 ]]; then
    TP=$((30*60))
  elif [[ tp -eq 3 ]]; then
    TP=$((60*60))
  elif [[ tp -eq 4 ]]; then
    TP=$((90*60))
  elif [[ tp -eq 5 ]]; then
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
    echo "+---------------------------------------------------------------+"
    echo "+ - - Programa que sera finalizado: "
    echo "+ - - - - - - - - -"
    echo "+ - - [1] VLC"
    echo "+ - - [2] Firefox"
    echo "+ - - [3] Chrome"
    echo "+ - - - - - - - - -"
    echo "+ - - [0] Sair"
    read -p "+ - - :: " pro
  done

  if [[ pro -eq 1 ]]; then
    PRO='vlc'
  elif [[ pro -eq 2 ]]; then
    PRO='firefox'
  elif [[ pro -eq 3 ]]; then
    PRO='chrome'
  else
    Finalizar
    return
  fi

  # checa se o programa esta em execucao
  if ! pgrep -x $PRO > /dev/null; then
    SYSMSG="O programa ${PRO} nao esta em execucao."
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
  until echo $SH | grep -E '^[sn0].{0}$'; do
    echo "+---------------------------------------------------------------+"
    echo "+ - - Desligar o computador tambem? (s/n)"
    echo "+ - - 0 para sair"
    read -p "+ - - :: " SH
  done

  if [[ SH -eq 0 ]]; then
    Finalizar
    return
  fi
  
  Escolha $SH $PRO $TP
}	
#
#
function Escolha() {
  if [[ "$SH" == s ]]; then
    if [[ "$USER" == root ]]; then	
      clear 
      SH=SIM
      Cronometro $PRO $SH $TP
      # Shutdown
      echo 'root'
    else
      SYSMSG="Comando shutdwon nao permitido para o usuario"
      StartPrograma
    fi
  else
    clear
    SH=NAO
    Cronometro $PRO $SH $TP
  fi
  Finalizar
}
#
#  
function DadosFoot() {
  #TempoConvert $TP
  array=("Tempo para fechar o programa: ${HR} - `date`")
  array[1]="Tempo para fechar o programa: ${HR} - `date`"
  array[2]="Tempo para fechar o programa: ${HR} - `date`"
  array[3]="Programa: ${PRO}"
  array[4]="Programa: ${PRO}"
  array[5]="Desligar o computador tambem? (s/n): ${SH}"
  array[6]="Desligar o computador tambem? (s/n): ${SH}"
  array[7]="\\o/"
  array[8]="\\o/*"
  array[9]="\\o/**"
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
    echo "+-----------------------------------------------------------------------------------+"
    echo "+									+"
    echo "+ + Finalizar o programa - "$PRO" - em:" $TP "segundos "
    echo "+									+"
    echo "+------------------------------------------------------------------------------------+"
    #TempoConvert $TP
    TP=$(($TP-1))
    FuncaoFoot ${array[@]}
    # echo $RANDOM
    sleep 1
    clear
  done
  ProgKill $PRO
  return
}
#
#
function TempoConvert() {
  if [[ "$TP" < 3600 ]]; then 
    HR=""
  elif [[ "$TP" > 3600 ]]; then
    HR="hr"
  elif "$TP" >= 7200 && "$TP" < 10800; then
    HR="2h"
  else [[ "$TP" > 10800 ]] 
    HR="3h"
  fi 2>&-
}
#
#
function ProgKill() {
  pkill $PRO
  Top
  echo +--------------------------------------+
  echo +
  echo + + $PRO" -> FINALIZADO" 
  echo +
  echo +--------------------------------------+
  sleep 2
}
#
#
function Shutdown () {
  Top
  echo "E agora e hora de dar tchau"
  sleep 2
  echo "TCHAAU..."
  # xmms musica.mp3 &
  # sleep 180
  # killall xmms
  shutdown -h now
}
#
function Continuar() {
    SN=""
    until echo $SN | grep -E '^[sn].{0}$'; do
      echo "Deseja continuar? (s/n)"
      read -p ":: " SN
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
  #Pergunta $PRO $TP
}
#
function Finalizar() {
  echo "Bye"
}
#
function Start() {
  if [ "$USER" == root ]; then
    StartPrograma
  else   
    echo "Usuario $USER - non root"
    Continuar
  fi
}
#
###### inicio do programa ##############################################
# 
Start
#