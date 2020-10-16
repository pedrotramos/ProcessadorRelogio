TIMER_INIT:
    # Seta os registradores do timer todos com zero.
    mov $0, %tsu
    mov $0, %tsd
    mov $0, %tmu
    mov $0, %tmd
    mov $0, %thu
    mov $0, %thd

START:
    # Seta os registradores de hora, minuto e segundo com zero.
	mov $0, %su
	mov $0, %sd
	mov $0, %mu
	mov $0, %md
	mov $0, %hu
	mov $0, %hd
    # Seta os registradores de hora_AMPM, minuto_AMPM e AM/PM.
    mov $2, %hu2
    mov $1, %hd2
    mov $12, %empty # Define um espaço vazio.
    mov $10, %ampm # 10 = A, 15 = P

MAIN:
TIMER:
    # Pega SW[4] e passa seu valor para %play.
    getio $4, %play
    # Se SW[4] = 1, vai para o temporizador.
    cmp $1, %play
    je PLAY_TIMER
    # Pega SW[3] e passa seu valor para %temp.
    getio $3, %temp
    # Se SW[4] = 1, vai para a configuração do temporizador.
    cmp $1, %temp
    je CONFIG_TIMER

NEED_CONFIG:
    # Pega SW[2] e passa seu valor para %config.
    getio $2, %config
    # Se SW[2] = 1, vai para a configuração do relógio.
    cmp $1, %config
    je CONFIG

SET_BASE:
    # Pega SW[1] e passa seu valor para %base.
    getio $1, %base
    # Se SW[1] = 0, usa o modelo hh:mm:ss.
    cmp $0, %base
    je DEFAULT
    # Se SW[1] = 1, usa o modelo hh:mm A/P.
    cmp $1, %base
    je AMPM

DEFAULT:
    # Passa os valores contidos nos registradores para o 
    # display hexadecimal de forma hh:mm:ss.
	display $14, %su
	display $15, %sd
	display $16, %mu
	display $17, %md
	display $18, %hu
	display $19, %hd
    jmp SECOND

AMPM:
    # Passa os valores contidos nos registradores para o 
    # display hexadecimal de forma hh:mm A/P.
	display $14, %ampm
	display $15, %empty
	display $16, %mu
	display $17, %md
	display $18, %hu2
	display $19, %hd2
    jmp SECOND

SECOND:
    # Checa se passa 1 segundo
    getio $20, %time
    # Se passou pula para SU e contabiliza a passagem de 1 segundo no relógio.
    cmp $1, %time
    je SU
    # Caso contrário pula para o MAIN e verifica as switches novamente.
    jmp MAIN

SU:
    # Reset do time (Zera o flipflop que indica que um segundo já se passou).
    getio $21, %time
SU_POS_TIMER_DEC:
    # Checa se a unidade dos segundos vale 9.
    cmp $9, %su
    # Se verdadeiro pula para a checagem da casa das dezenas de segundo.
    je SD
    # Caso contrário, incrementa a unidade de segundo e reinicia o loop 
    # principal.
    add $1, %su
    jmp MAIN

SD:
    # Zera a unidade de segundo.
    mov $0, %su
    # Checa se a dezena dos segundos vale 5.
    cmp $5, %sd
    # Se verdadeiro pula para a checagem da casa das unidades de minuto.
    je MU
    # Caso contrário, incrementa a dezena de segundo e reinicia o loop 
    # principal.
    add $1, %sd
    jmp MAIN

MU:
    # Zera a dezena de segundo.
    mov $0, %sd
    # Checa se a unidade dos minutos vale 9.
    cmp $9, %mu
    # Se verdadeiro pula para a checagem da casa das dezenas de minuto.
    je MD
    # Caso contrário, incrementa a unidade de minuto e reinicia o loop 
    # principal.
    add $1, %mu
    jmp MAIN

MD:
    # Zera a unidade de minuto.
    mov $0, %mu
    # Checa se a dezena dos minutos vale 5.
    cmp $5, %md
    # Se verdadeiro pula para a checagem da casa das unidades de hora.
    je HU
    # Caso contrário, incrementa a dezena de minuto e reinicia o loop 
    # principal.
    add $1, %md
    jmp MAIN

HU:
    # Zera a dezena de minuto.
    mov $0, %md
    # Verifica se a unidade da hora AMPM é igual a 1.
    cmp $1, %hu2
    # Se for, pula para a checagem de se a hora AMPM é 11.
    je AMPM_CHECK_HD11
    # Verifica se a unidade da hora AMPM é igual a 2.
    cmp $2, %hu2
    # Se for, pula para a checagem de se a hora AMPM é 12.
    je AMPM_CHECK_HD12
    # Pula para a atualização da unidade da hora AMPM.
    jmp HU2

AMPM_CHECK_HD11:
    # Checa se a dezena da hora AMPM é 1.
    cmp $1, %hd2
    # Se for, pula para a checagem de se o relogio deve passar para 12AM
    # ou para 12PM.
    je AMPM_CHECK_AP11
    # Caso contrário, incrementa a unidade da hora AMPM e pula para a
    # atualização da unidade da hora padrão.
    add $1, %hu2
    jmp HU_P2

AMPM_CHECK_HD12:
    # Checa se a dezena da hora AMPM é 1.
    cmp $1, %hd2
    # Se for, pula para a alteração da hora para 01.
    je AMPM_AP12
    # Caso contrário, incrementa a unidade da hora AMPM e pula para a
    # atualização da unidade da hora padrão.
    add $1, %hu2
    jmp HU_P2

AMPM_CHECK_AP11:
    # Checa se o relógio está no período AM ou no período PM.
    cmp $15, %ampm
    # Se for PM pula para START que reinicia o relógio em 00:00:00 e 12:00 AM.
    je START
    # Caso contrário incrementa a hora AMPM para 12, passa o período de AM
    # para PM e pula para a atualização da unidade da hora padrão.
    add $1, %hu2
    mov $15, %ampm
    jmp HU_P2

AMPM_AP12:
    # Define a hora AMPM como 01 e pula para a atualização da unidade da hora
    # padrão.
    mov $1, %hu2
    mov $0, %hd2
    jmp HU_P2

HU2:
    # Checa se a unidade da hora AMPM é 9.
    cmp $9, %hu2
    # Se for, pula para a checagem da dezena da hora AMPM.
    je HD2
    # Caso contrário, incrementa a unidade da hora AMPM e pula para a 
    # para a atualização da unidade da hora padrão.
    add $1, %hu2
    jmp HU_P2

HD2:
    # Zera a unidade da hora AMPM e incrementa a dezena da hora AMPM.
    mov $0, %hu2
    add $1, %hd2

HU_P2:
    # Checa se a unidade das horas vale 9.
    cmp $9, %hu
    # Se verdadeiro pula para o incremento da casa das dezenas de hora.
    je HD
    # Caso contrário, incrementa a unidade de hora e reinicia o loop principal.
    add $1, %hu
    jmp MAIN

HD:
    # Zera a unidade de hora.
    mov $0, %hu
    # Incrementa a unidade de hora e reinicia o loop principal.
    add $1, %hd
    jmp MAIN

CONFIG:
KEY0:
    # Pega o estado de KEY[0].
    getio $10, %key0
    # Checa se KEY[0] está apertado.
    cmp $0, %key0
    # Se estiver, pula para a checagem de se KEY[0] já foi liberado.
    je KR0

KEY1:
    # Pega o estado de KEY[1].
    getio $11, %key1
    # Checa se KEY[1] está apertado.
    cmp $0, %key1
    # Se estiver, pula para a checagem de se KEY[1] já foi liberado.
    je KR1

KEY2:
    # Pega o estado de KEY[2].
    getio $12, %key2    
    # Checa se KEY[2] está apertado.
    cmp $0, %key2
    # Se estiver, pula para a checagem de se KEY[2] já foi liberado.
    je KR2
    # Caso contrário pula para o funcionamento do relógio.
    jmp SET_BASE

KR0:
    # Aguarda KEY[0] ser liberada ou 1 segundo passar para alterar a 
    # configuração da unidade do minuto.
    getio $10, %key0
    cmp $1, %key0
    je SET_MU
    getio $20, %time
    cmp $1, %time
    je SET_MU
    jmp KR0

KR1:
    # Aguarda KEY[1] ser liberada ou 1 segundo passar para alterar a 
    # configuração da dezena do minuto.
    getio $11, %key1
    cmp $1, %key1
    je SET_MD
    getio $20, %time
    cmp $1, %time
    je SET_MD
    jmp KR1

KR2:
    # Aguarda KEY[2] ser liberada ou 1 segundo passar para alterar a 
    # configuração da hora.
    getio $12, %key2
    cmp $1, %key2
    je SET_HU
    getio $20, %time
    cmp $1, %time
    je SET_HU
    jmp KR2

SET_MU:
    # Se a unidade do minuto é 9 pula para o reset da unidade do minuto.
    # Caso contrário, incrementa a unidade do minuto e pula para o 
    # funcionamento do relógio.
    cmp $9, %mu
    je RST_MU
    add $1, %mu
    jmp SET_BASE

RST_MU:
    # Zera a unidade do minuto e pula para o funcionamento do relógio.
    mov $0, %mu
    jmp SET_BASE

SET_MD:
    # Se a dezena do minuto é 5 pula para o reset da dezena do minuto.
    # Caso contrário, incrementa a dezena do minuto e pula para o 
    # funcionamento do relógio.
    cmp $5, %md
    je RST_MD
    add $1, %md
    jmp SET_BASE

RST_MD:
    # Zera a dezena do minuto e pula para o funcionamento do relógio.
    mov $0, %md
    jmp SET_BASE

SET_HU:
    # Se a unidade da hora AMPM é 1 pula para a checagem da dezena da hora 
    # AMPM. Caso contrário, checa se a unidade da hora AMPM é 2. Se for, pula
    # para a checagem de se a dezena da hora AMPM é 1. Caso contrário, pula
    # para a alteração da unidade da hora AMPM.
    cmp $1, %hu2
    je SET_AMPM_CHECK_HD11
    cmp $2, %hu2
    je SET_AMPM_CHECK_HD12
    jmp SET_HU2

SET_AMPM_CHECK_HD11:
    # Verifica se a dezena da hora AMPM é 1. Se for, pula para a alteração de
    # AM para PM ou de PM para AM. Caso contrário, incrementa a unidade da hora
    # AMPM e vai para a alteração da unidade da hora padrão.
    cmp $1, %hd2
    je SET_AMPM_CHECK_AP11
    add $1, %hu2
    jmp SET_HU_P2

SET_AMPM_CHECK_HD12:
    # Verifica se a dezena da hora AMPM é 1. Se for, pula para a configuração
    # da hora AMPM como 01. Caso contrário, incrementa a unidade da hora AMPM
    # e pula para a alteração da unidade da hora padrão.
    cmp $1, %hd2
    je SET_AMPM_AP12
    add $1, %hu2
    jmp SET_HU_P2

SET_AMPM_CHECK_AP11:
    # Verifica se o estado AM/PM é PM. Se for pula para o reset da hora.
    # Caso contrário, incrementa a unidade da hora e pula para a alteração
    # da unidade da hora padrão.
    cmp $15, %ampm
    je RST_H
    add $1, %hu2
    mov $15, %ampm
    jmp SET_HU_P2

SET_AMPM_AP12:
    # Seta a hora AMPM como 01 e pula para a alteração da unidade da hora
    # padrão.
    mov $1, %hu2
    mov $0, %hd2
    jmp SET_HU_P2

SET_HU2:
    # Verifica se a unidade da hora AMPM é 9. Se for, pula para a alteração da
    # dezena da hora AMPM. Caso contrário, incrementa a unidade da hora AMPM e
    # pula para a alteração da unidade da hora padrão.
    cmp $9, %hu2
    je SET_HD2
    add $1, %hu2
    jmp SET_HU_P2

SET_HD2:
    # Zera a unidade da hora AMPM e incrementa a dezena da hora AMPM.
    mov $0, %hu2
    add $1, %hd2

SET_HU_P2:
    # Checa se a unidade das horas vale 9.
    cmp $9, %hu
    # Se verdadeiro pula para o incremento da casa das dezenas de hora.
    je SET_HD
    # Caso contrário, incrementa a unidade de hora e pula para o funcionamento
    # do relógio.
    add $1, %hu
    jmp SET_BASE

SET_HD:
    # Zera a unidade de hora.
    mov $0, %hu
    # Incrementa a unidade de hora e pula para o funcionamento do relógio.
    add $1, %hd
    jmp SET_BASE

RST_H:
    # Faz o reset da hora para 00 e 12 AM. Em seguida, pula para o 
    # funcionamento do relógio.
    mov $0, %hu
	mov $0, %hd
    mov $2, %hu2
    mov $1, %hd2
    mov $10, %ampm
    jmp SET_BASE

CONFIG_TIMER:
TKEY0:
    # Verifica se KEY[0] está apertado. Se estiver, pula para a verificação
    # de se KEY[0] já foi liberado.
    getio $10, %key0
    cmp $0, %key0
    je TKR0

TKEY1:
    # Verifica se KEY[1] está apertado. Se estiver, pula para a verificação
    # de se KEY[1] já foi liberado.
    getio $11, %key1
    cmp $0, %key1
    je TKR1

TKEY2:
    # Verifica se KEY[2] está apertado. Se estiver, pula para a verificação
    # de se KEY[2] já foi liberado.
    getio $12, %key2
    cmp $0, %key2
    je TKR2  

TKEY3:
    # Verifica se KEY[3] está apertado. Se estiver, pula para a verificação
    # de se KEY[3] já foi liberado. Caso contrário, pula para o display da
    # configuração do timer.
    getio $13, %key3
    cmp $0, %key3
    je TKR3
    jmp DISPLAY_TIMER_CONFIG

TKR0:
    # Aguarda KEY[0] ser liberada ou 1 segundo passar para alterar a 
    # configuração dos segundos do timer.
    getio $10, %key0
    cmp $1, %key0
    je SET_S
    getio $20, %time
    cmp $1, %time
    je SET_S
    jmp TKR0

TKR1:
    # Aguarda KEY[1] ser liberada ou 1 segundo passar para alterar a 
    # configuração dos minutos do timer.
    getio $11, %key1
    cmp $1, %key1
    je SET_M
    getio $20, %time
    cmp $1, %time
    je SET_M
    jmp TKR1

TKR2:
    # Aguarda KEY[2] ser liberada ou 1 segundo passar para alterar a 
    # configuração das horas do timer.
    getio $12, %key2
    cmp $1, %key2
    je SET_H
    getio $20, %time
    cmp $1, %time
    je SET_H
    jmp TKR2

TKR3:
    # Aguarda KEY[3] ser liberada ou 1 segundo passar para fazer o reset
    # completo do timer.
    getio $13, %key3
    cmp $1, %key3
    je RST_TIMER_ALL
    getio $20, %time
    cmp $1, %time
    je RST_TIMER_ALL
    jmp TKR3

SET_S:
    # Checa de a unidade do segundo é 9. Se for, pula para o incremento
    # da dezena dos segundos. Caso contrário, incrementa a unidade do segundo
    # e pula para o display da configuração do timer.
    cmp $9, %tsu
    je INC_SD
    add $1, %tsu
    jmp DISPLAY_TIMER_CONFIG

INC_SD:
    # Zera a unidade do segundo do timer e checa se a dezena do segundo é 5.
    # Se for, pula para o reset dos segundos do timer. Caso contrário,
    # incrementa a dezena do segundo e pula para o display da configuração do
    # timer.
    mov $0, %tsu
    cmp $5, %tsd
    je RST_TIMER_S
    add $1, %tsd
    jmp DISPLAY_TIMER_CONFIG

RST_TIMER_S:
    # Zera a dezena do segundo do timer e pula para o display da configuração
    # do timer.
    mov $0, %tsd
    jmp DISPLAY_TIMER_CONFIG

SET_M:
    # Checa de a unidade do minuto é 9. Se for, pula para o incremento
    # da dezena dos minutos. Caso contrário, incrementa a unidade do minuto
    # e pula para o display da configuração do timer.
    cmp $9, %tmu
    je INC_MD
    add $1, %tmu
    jmp DISPLAY_TIMER_CONFIG

INC_MD:
    # Zera a unidade do minuto do timer e checa se a dezena do minuto é 5.
    # Se for, pula para o reset dos minutos do timer. Caso contrário,
    # incrementa a dezena do minuto e pula para o display da configuração do
    # timer.
    mov $0, %tmu
    cmp $5, %tmd
    je RST_TIMER_M
    add $1, %tmd
    jmp DISPLAY_TIMER_CONFIG

RST_TIMER_M:
    # Zera a dezena do minuto do timer e pula para o display da configuração
    # do timer.
    mov $0, %tmd
    jmp DISPLAY_TIMER_CONFIG

SET_H:
    # Checa de a unidade da hora é 9. Se for, pula para o incremento
    # da dezena das horas. Caso contrário, incrementa a unidade da hora
    # e pula para o display da configuração do timer.
    cmp $9, %thu
    je INC_HD
    add $1, %thu
    jmp DISPLAY_TIMER_CONFIG

INC_HD:
    # Zera a unidade da hora do timer e checa se a dezena da hora é 5.
    # Se for, pula para o reset dos minutos do timer. Caso contrário,
    # incrementa a dezena da hora e pula para o display da configuração do
    # timer.
    mov $0, %thu
    cmp $9, %thd
    je RST_TIMER_H
    add $1, %thd
    jmp DISPLAY_TIMER_CONFIG

RST_TIMER_H:
    # Zera a dezena da hora do timer e pula para o display da configuração
    # do timer.
    mov $0, %thd
    jmp DISPLAY_TIMER_CONFIG

RST_TIMER_ALL:
    # Zera todos os registradores do timer e pula para o display da
    # configuração do timer.
    mov $0, %tsu
    mov $0, %tsd
    mov $0, %tmu
    mov $0, %tmd
    mov $0, %thu
    mov $0, %thd
    jmp DISPLAY_TIMER_CONFIG

DISPLAY_TIMER_CONFIG:
    # Faz o display da configuração do timer.
    display $14, %tsu
	display $15, %tsd
	display $16, %tmu
	display $17, %tmd
	display $18, %thu
	display $19, %thd
    jmp SECOND

PLAY_TIMER: 
    # Faz o display do timer.
    display $14, %tsu
	display $15, %tsd
	display $16, %tmu
	display $17, %tmd
	display $18, %thu
	display $19, %thd

SECOND_TIMER_PLAY:
    # Espera passar 1 segundo e pula para o funcionamento do temporizador.
    getio $20, %time
    cmp $1, %time
    je TSU
    jmp SECOND_TIMER_PLAY

TSU:
    # Reset do time
    getio $21, %time
    # Checa se a unidade dos segundos vale 0.
    cmp $0, %tsu
    # Se verdadeiro pula para a checagem da casa das dezenas de segundo.
    je TSD
    # Caso contrário, decrementa a unidade de segundo e pula para o display do
    # timer.
    sub $1, %tsu
    jmp DISPLAY_TIMER

TSD:
    # Muda para 9 a unidade de segundo.
    mov $9, %tsu
    # Checa se a dezena dos segundos vale 0.
    cmp $0, %tsd
    # Se verdadeiro pula para a checagem da casa das unidades de minuto.
    je TMU
    # Caso contrário, decrementa a dezena de segundo e pula para o display do
    # timer.
    sub $1, %tsd
    jmp DISPLAY_TIMER

TMU:
    # Muda para 5 a dezena de segundo.
    mov $5, %tsd
    # Checa se a unidade dos minutos vale 0.
    cmp $0, %tmu
    # Se verdadeiro pula para a checagem da casa das dezenas de minuto.
    je TMD
    # Caso contrário, decrementa a unidade de minuto e pula para o display do
    # timer.
    sub $1, %tmu
    jmp DISPLAY_TIMER

TMD:
    # Muda para 9 a unidade de minuto.
    mov $9, %tmu
    # Checa se a dezena dos minutos vale 0.
    cmp $0, %tmd
    # Se verdadeiro pula para a checagem da casa das unidades de hora.
    je THU
    # Caso contrário, decrementa a dezena de minuto e pula para o display do
    # timer.
    sub $1, %tmd
    jmp DISPLAY_TIMER

THU:
    # Muda para 5 a dezena de minuto.
    mov $5, %tmd
    # Checa se a unidade das horas vale 0.
    cmp $0, %thu
    # Se verdadeiro pula para o incremento da casa das dezenas de hora.
    je THD
    # Caso contrário, decrementa a unidade de hora e pula para o display do
    # timer.
    sub $1, %thu
    jmp DISPLAY_TIMER

THD:
    # Checa se a dezena da hora é 0.
    cmp $0, %thd
    # Se verdadeiro pula para o fim do timer.
    je END_TIMER
    # Muda para 9 a unidade de hora.
    mov $9, %thu
    # Decrementa a dezena de hora e pula para o display do timer.
    sub $1, %thd
    jmp DISPLAY_TIMER

END_TIMER:
    # Seta os registradores do timer todos com zero.
    mov $0, %tsu
    mov $0, %tsd
    mov $0, %tmu
    mov $0, %tmd
    mov $0, %thu
    mov $0, %thd
    # Faz o display do timer.
    jmp DISPLAY_TIMER

DISPLAY_TIMER:
    # Faz o display do timer.
    display $14, %tsu
	display $15, %tsd
	display $16, %tmu
	display $17, %tmd
	display $18, %thu
	display $19, %thd
    # Pula para o funcionamento do relógio.
    jmp SU_POS_TIMER_DEC