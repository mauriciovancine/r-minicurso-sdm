# Repositório de dados do Minicurso 3 - IX Congresso Brasileiro de Herpetologia

## MINICURSO 3: Introdução à modelagem de distribuição de espécies usando a linguagem R: teoria e prática

**Ministrantes**: Maurício Humberto Vancine e João Gabriel Ribeiro Giovanelli

**Instituição**: Universidade Estadual Paulista (UNESP), Câmpus de Rio Claro, Rio Claro, SP

**Vagas**: 20

**Resumo**

A ampla quantidade e disponibilidade de dados sobre a biodiversidade e variáveis ambientais têm permitido a utilização de diversas análises biogeográficas e macroecológicas, dentre elas, os Modelos de Distribuição de Espécies (MDEs). Nesse minicurso, iremos oferecer uma introdução teórica e prática à técnica de MDEs utilizando a linguagem R. Primeiramente serão apresentados os principais conceitos da teoria de nicho ecológico (Grinnell, Elton e Hutchinson) e da teoria de MDEs (espaço geográfico (G), espaço ambiental (E) e diagrama Biótico-Abiótico-Movimentação (BAM)). Seguida à parte teórica, apresentaremos as principais bases de dados (ocorrências e variáveis ambientais), tipos de algoritmos (apenas presença - BIOCLIM, Mahalanobis e Gower; presença e ausência - GLM e Random Forest; e presença e background - Maxent e SVM), avaliação dos modelos (ROC, AUC e TSS), limites de corte (thresholds) e algumas abordagens de consenso de modelos (ensemble por frequência e média ponderada). A parte prática será focada na construção dos modelos através da linguagem R, onde abordaremos: (i) introdução à linguagem R, (ii) obtenção e ajustes dos dados de ocorrências e variáveis ambientais, (iii) ajuste e predição dos modelos e métricas de avaliação dos mesmos, (iv) automatização da construção dos MDEs, (v) consenso (ensembles), e (vi) composição dos mapas.

---

### Informações aos participantes

**Data**: 22/07/2019 (8:00 h - 16:00 h)

**Local**: [Centro de Convenções da Unicamp](https://goo.gl/maps/x2JnxBeGkx1yZghu6)

**Ementa**: [Ementa]()

**Contato**: 
Para mais informações ou dúvidas, envie e-mail para:

- Organização da IX CBH (9cbh@criandoelo.com.br)
- Maurício Vancine (mauricio.vancine@gmail.com)
- João Giovanelli (jgiovanelli@gmail.com)

---

### Instruções aos participantes

**Hardware** <br>
Será necessário que todos tragam seus próprios notebooks.

**Softwares**
1. R e RStudio <br>
Instalar a versão mais recente do R (3.6.1): https://www.r-project.org/ <br>
Instalar o RStudio: https://www.rstudio.com/ <br>
Vídeo de instalação: https://youtu.be/l1bWvZMNMCM <br>
Curso de introdução à linguagem R: http://www.bosontreinamentos.com.br/category/programacao-em-r/

2. Java <br>
Instalar o Java (atentar para versão 64 bits): https://www.java.com/en/download/manual.jsp <br>

3. Maxent <br>
Baixar o Maxent: https://biodiversityinformatics.amnh.org/open_source/maxent/

**Instalar os pacotes no R** <br>
Com o R e o RStudio instalados, basta abrir e rodar o [script](https://gitlab.com/mauriciovancine/course-sdm/blob/master/00_scripts/00_script_install_packages.R) para instalar os pacotes necessários. <br>
Abrir o script no software RStudio e rodar cada comando. Basta colocar o cursos na linha do comando e precionar: `Crtl + Enter`, como mostra o gif abaixo:

![Alt Text](https://appsilon.com/wp-content/uploads/2019/03/blog_code_execution_optimized.gif)

**Mover o arquivo do Maxent para a pasta do pacote dismo** <br>
Uma vez instalados os pacotes no R, deszip o arquivo baixado no item 3. Maxent, e mova o arquivo **maxent.jar** para a pasta: <br>

Windows: C:/Program Files/R/R-3.6.1/library/dismo <br>
Linux e Mac:   /home/usuario/R/x86_64-pc-linux-gnu-library/3.6/dismo/java

**Dúvidas ou dificuldades** <br>
Para ajuda, envie e-mail para: <br>

- Maurício Vancine (mauricio.vancine@gmail.com)

---