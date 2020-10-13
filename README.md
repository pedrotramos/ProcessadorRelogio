# Projeto 1-Design de Computadores
### Alunos: Matheus Pellizzon, Pedro Teófilo Ramos e Pedro Paulo Telho
<br />

### Diagrama da arquitetura 
<p align="center">
  <img src="top_level_rtl.jpg" width="1000" title="RTL viewer">
</p>
<br />

### Configurações dos componentes

##### Switches
<ul>
  <li>SW 0: Se 0 = usa o modelo hh:mm:ss; Se 1 = usa o modelo hh:mm A/P;</li>
  <li>SW 1: controla temporizador;</li>
  <li>SW 2: controla a configuração do relógio;</li>
  <li>SW 3: seletor da base de tempo.</li>
</ul>

##### Botões
<ul>
  <li>Key 0: incrementa unidade de minuto;</li>
  <li>Key 1: incrementa dezena de minuto;</li>
  <li>Key 2: incrementa hora.</li>
</ul>
<br />

### Requisitos do projeto
##### Obrigatórios
- [x] indica horas, minutos e segundos
- [x] possui sistema para acertar horário
- [x] possui seleção para base de tempo

##### Opcionais
###### sobem meio conceito (+)
- [x] indicação do horário com base em 12 horas - AM/PM
- [] sistema de despertador
- [] temporizador com contagem regressiva

###### sobem um conceito
- [x] assembler em Python
- [] pilha controlada por hardware
- [] instrução de chamada de sub-rotina com um nível 
