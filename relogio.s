# Seta os registradores do timer de hora, minuto e segundo com zero.
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

NEED_CONFIG:
    # Pega SW[2] e passa seu valor para %config.
    getio $2, %config
    # Se SW[2] = 1, vai para a configuração do relógio
    cmp $1, %config
    je CONFIG

PLAY_PAUSE:
    getio $4, %play
    cmp $1, %play
    je PLAY_TIMER

CHECK_TIMER:
    # Pega SW[1] e passa seu valor para %base.
    getio $1, %temp
    # Se SW[1] = 0, usa o modelo hh:mm:ss.
    cmp $1, %temp
    je TIMER

SET_BASE:
    # Pega SW[0] e passa seu valor para %base.
    getio $0, %base
    # Se SW[0] = 0, usa o modelo hh:mm:ss.
    cmp $0, %base
    je DEFAULT
    # Se SW[0] = 1, usa o modelo hh:mm A/P.
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
    # Caso contrário, passa os valores contidos nos registradores para o 
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
    cmp $1, %time
    je SU
    jmp MAIN

SU:
    # Reset do time
    getio $21, %time
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
    cmp $1, %hu2
    je AMPM_CHECK_HD11
    cmp $2, %hu2
    je AMPM_CHECK_HD12
    jmp HU2

AMPM_CHECK_HD11:
    cmp $1, %hd2
    je AMPM_CHECK_AP11
    add $1, %hu2
    jmp HU_P2

AMPM_CHECK_HD12:
    cmp $1, %hd2
    je AMPM_CHECK_AP12
    add $1, %hu2
    jmp HU_P2

AMPM_CHECK_AP11:
    cmp $15, %ampm
    je START
    add $1, %hu2
    mov $15, %ampm
    jmp HU_P2

AMPM_CHECK_AP12:
    mov $1, %hu2
    mov $0, %hd2
    jmp HU_P2

HU2:
    cmp $9, %hu2
    je HD2
    add $1, %hu2
    jmp HU_P2

HD2:
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
    getio $10, %key0
    cmp $0, %key0
    je KR0

KEY1:
    getio $11, %key1
    cmp $0, %key1
    je KR1

KEY2:
    getio $12, %key2
    cmp $0, %key2
    je KR2
    jmp SET_BASE

KR0:
    getio $10, %key0
    cmp $1, %key0
    je SET_MU
    getio $20, %time
    cmp $1, %time
    je SET_MU
    jmp KR0

KR1:
    getio $11, %key1
    cmp $1, %key1
    je SET_MD
    getio $20, %time
    cmp $1, %time
    je SET_MD
    jmp KR1

KR2:
    getio $12, %key2
    cmp $1, %key2
    je SET_HU
    getio $20, %time
    cmp $1, %time
    je SET_HU
    jmp KR2

SET_MU:
    cmp $9, %mu
    je RST_MU
    add $1, %mu
    jmp SET_BASE

RST_MU:
    mov $0, %mu
    jmp SET_BASE

SET_MD:
    cmp $5, %md
    je RST_MD
    add $1, %md
    jmp SET_BASE

RST_MD:
    mov $0, %md
    jmp SET_BASE

SET_HU:
    cmp $1, %hu2
    je SET_AMPM_CHECK_HD11
    cmp $2, %hu2
    je SET_AMPM_CHECK_HD12
    jmp SET_HU2

SET_AMPM_CHECK_HD11:
    cmp $1, %hd2
    je SET_AMPM_CHECK_AP11
    add $1, %hu2
    jmp SET_HU_P2

SET_AMPM_CHECK_HD12:
    cmp $1, %hd2
    je SET_AMPM_CHECK_AP12
    add $1, %hu2
    jmp SET_HU_P2

SET_AMPM_CHECK_AP11:
    cmp $15, %ampm
    je RST_H
    add $1, %hu2
    mov $15, %ampm
    jmp SET_HU_P2

SET_AMPM_CHECK_AP12:
    mov $1, %hu2
    mov $0, %hd2
    jmp SET_HU_P2

SET_HU2:
    cmp $9, %hu2
    je SET_HD2
    add $1, %hu2
    jmp SET_HU_P2

SET_HD2:
    mov $0, %hu2
    add $1, %hd2

SET_HU_P2:
    # Checa se a unidade das horas vale 9.
    cmp $9, %hu
    # Se verdadeiro pula para o incremento da casa das dezenas de hora.
    je SET_HD
    # Caso contrário, incrementa a unidade de hora e reinicia o loop principal.
    add $1, %hu
    jmp SET_BASE

SET_HD:
    # Zera a unidade de hora.
    mov $0, %hu
    # Incrementa a unidade de hora e reinicia o loop principal.
    add $1, %hd
    jmp SET_BASE

RST_H:
    mov $0, %hu
	mov $0, %hd
    mov $2, %hu2
    mov $1, %hd2
    mov $10, %ampm
    jmp SET_BASE

TIMER:
CONFIG_TIMER:
TKEY0:
    getio $10, %key0
    cmp $0, %key0
    je TKR0

TKEY1:
    getio $11, %key1
    cmp $0, %key1
    je TKR1

TKEY2:
    getio $12, %key2
    cmp $0, %key2
    je TKR2
    jmp DISPLAY_TIMER   

TKR0:
    getio $10, %key0
    cmp $1, %key0
    je SET_S
    getio $20, %time
    cmp $1, %time
    je SET_S
    jmp TKR0

TKR1:
    getio $11, %key1
    cmp $1, %key1
    je SET_M
    getio $20, %time
    cmp $1, %time
    je SET_M
    jmp TKR1

TKR2:
    getio $12, %key2
    cmp $1, %key2
    je SET_H
    getio $20, %time
    cmp $1, %time
    je SET_H
    jmp TKR2

SET_S:
    cmp $9, %tsu
    je INC_SD
    add $1, %tsu
    jmp DISPLAY_TIMER

INC_SD:
    mov $0, %tsu
    cmp $5, %tsd
    je RST_TS
    add $1, %tsd
    jmp DISPLAY_TIMER

RST_TS:
    mov $0, %tsd
    jmp DISPLAY_TIMER

SET_M:
    cmp $9, %tmu
    je INC_MD
    add $1, %tmu
    jmp DISPLAY_TIMER

INC_MD:
    mov $0, %tmu
    cmp $5, %tmd
    je RST_TM
    add $1, %tmd
    jmp DISPLAY_TIMER

RST_TM:
    mov $0, %tmd
    jmp DISPLAY_TIMER

SET_H:
    cmp $9, %thu
    je INC_HD
    add $1, %thu
    jmp DISPLAY_TIMER

INC_HD:
    mov $0, %thu
    cmp $9, %thd
    je RST_TH
    add $1, %thd
    jmp DISPLAY_TIMER

RST_TH:
    mov $0, %thd
    jmp DISPLAY_TIMER

DISPLAY_TIMER:
    # Passa os valores contidos nos registradores para o 
    # display hexadecimal de forma hh:mm:ss.
	display $14, %tsu
	display $15, %tsd
	display $16, %tmu
	display $17, %tmd
	display $18, %thu
	display $19, %thd
    jmp SECOND

PLAY_TIMER:
TSECOND:
    # Checa se passa 1 segundo
    getio $20, %time
    cmp $1, %time
    je TSU
    jmp SU 

TSU:
    # Checa se a unidade dos segundos vale 0.
    cmp $0, %tsu
    # Se verdadeiro pula para a checagem da casa das dezenas de segundo.
    je TSD
    # Caso contrário, incrementa a unidade de segundo e reinicia o loop 
    # principal.
    sub $1, %tsu
    jmp DISPLAY_TIMER

TSD:
    # Zera a unidade de segundo.
    mov $9, %tsu
    # Checa se a dezena dos segundos vale 5.
    cmp $0, %tsd
    # Se verdadeiro pula para a checagem da casa das unidades de minuto.
    je TMU
    # Caso contrário, incrementa a dezena de segundo e reinicia o loop 
    # principal.
    sub $1, %tsd
    jmp DISPLAY_TIMER

TMU:
    # Zera a dezena de segundo.
    mov $5, %tsd
    # Checa se a unidade dos minutos vale 9.
    cmp $0, %tmu
    # Se verdadeiro pula para a checagem da casa das dezenas de minuto.
    je TMD
    # Caso contrário, incrementa a unidade de minuto e reinicia o loop 
    # principal.
    sub $1, %tmu
    jmp DISPLAY_TIMER

TMD:
    # Zera a unidade de minuto.
    mov $9, %tmu
    # Checa se a dezena dos minutos vale 5.
    cmp $0, %tmd
    # Se verdadeiro pula para a checagem da casa das unidades de hora.
    je THU
    # Caso contrário, incrementa a dezena de minuto e reinicia o loop 
    # principal.
    sub $1, %tmd
    jmp DISPLAY_TIMER

THU:
    # Zera a dezena de minuto.
    mov $5, %tmd
    # Checa se a unidade das horas vale 9.
    cmp $0, %thu
    # Se verdadeiro pula para o incremento da casa das dezenas de hora.
    je THD
    # Caso contrário, incrementa a unidade de hora e reinicia o loop principal.
    sub $1, %thu
    jmp DISPLAY_TIMER

THD:
    cmp $0, %thd
    je END_TIMER
    # Zera a unidade de hora.
    mov $9, %thu
    # Incrementa a unidade de hora e reinicia o loop principal.
    sub $1, %thd
    jmp DISPLAY_TIMER

END_TIMER:
    # Seta os registradores do timer de hora, minuto e segundo com zero.
    mov $0, %tsu
    mov $0, %tsd
    mov $0, %tmu
    mov $0, %tmd
    mov $0, %thu
    mov $0, %thd
    jmp DISPLAY_TIMER