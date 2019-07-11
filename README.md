# Repositório de dados do Minicurso 3 - IX Congresso Brasileiro de Herpetologia

## MINICURSO 3: Introdução à modelagem de distribuição de espécies usando a linguagem R: teoria e prática

**Ministrantes**: Maurício Humberto Vancine e João Gabriel Ribeiro Giovanelli

**Instituição**: Universidade Estadual Paulista (UNESP), Câmpus de Rio Claro, Rio Claro, SP

**Vagas**: 20

**Resumo**

A ampla disponibilidade de dados sobre a biodiversidade e variáveis ambientais têm permitido a utilização de diversas análises biogeográficas e macroecológicas, dentre elas, os modelos de distribuição de espécies (MDE). Esse minicurso tem como intuito oferecer uma introdução teórica e prática à técnica de MDE, utilizando a linguagem R. Primeiramente serão apresentados os principais conceitos da teoria de nicho ecológico (Grinnell, Elton e Hutchinson) e da teoria de modelos (espaço geográfico (G), espaço ambiental (E) e diagrama Biótico-Abiótico-Movimentação (BAM)). Seguida à parte teórica, serão apresentados as principais bases de dados (ocorrências e variáveis ambientais), tipos de algoritmos (presença e ausência - GLM e Random Forest, apenas presença - BIOCLIM, Mahalanobis e Gower, e presença e background - Maxent e SVM), avaliação dos modelos (ROC, AUC e TSS), limites de corte (thresholds) e algumas abordagens de consenso de modelos (ensembles). A parte prática será focada na construção dos modelos através da linguagem R. Inicialmente será feito uma introdução à programação e manejo de dados espaciais na linguagem R, utilizando os pacotes raster e rgdal. Em seguida, será apresentado como obter dados de ocorrências e variáveis ambientais, através dos pacotes spooc e raster. Uma vez adquiridos os dados, serão feitas análises preliminares dos mesmos, como seleção de ocorrências (um ponto por célula) e de variáveis (correlação e PCA). Por fim, serão construídos modelos utilizando os algoritmos mencionados acima, além do cálculo das métricas de avaliação dos mesmos, utilizando os pacotes dismo, randomForest e kernlab.

---

### Informações aos participantes

**Data**: 22/07/2019 (8:00 h - 16:00 h)

**Local**: [Centro de Convenções da Unicamp](https://goo.gl/maps/x2JnxBeGkx1yZghu6)

**Contato**: 
Para mais informações ou dúvidas, envie e-mail para:

- Organização da IX CBH (9cbh@criandoelo.com.br)
- Maurício Vancine (mauricio.vancine@gmail.com)
- João Giovanelli (jgiovanelli@gmail.com)

---

### Instruções aos participantes

**Hardware** <br>
Será necessário que todos tragam seus próprios notebooks

**Softwares**
1. R e RStudio <br>
Baixar e instalar a versão mais recente do R (3.6.1): https://www.r-project.org/ <br>
Instalar o RStudio: https://www.rstudio.com/ <br>
Vídeo: https://youtu.be/l1bWvZMNMCM <br>
Curso de R: http://www.bosontreinamentos.com.br/category/programacao-em-r/

2. Java <br>
Baixar e instalar o Java: https://www.java.com/en/download/manual.jsp <br>
Windows: dois cliques no .exe <br>
Linux: enviar email (mauricio.vancine@gmail.com) <br>
Mac: Sei não...

3. Maxent <br>
Baixar o Maxent: https://biodiversityinformatics.amnh.org/open_source/maxent/

**Instalar pacotes no R** <br>
Com o R e RStudio instalados, basta rodar o [script](https://gitlab.com/mauriciovancine/course-sdm/blob/master/00_scripts/00_script_install_packages.R) para instalar os pacotes

![Alt Text](https://appsilon.com/wp-content/uploads/2019/03/blog_code_execution_optimized.gif)

**Mover o arquivo do Maxent para a pasta do pacote dismo** <br>
Uma vez instalados os pacotes, mova o arquivo **maxent.jar**, cujo download foi feito logo acima no item 3. Maxent, para a pasta: <br>

Windows: C:/Program Files/R/R-3.6.1/library/dismo <br>
Linux e Mac:   /home/mude/R/x86_64-pc-linux-gnu-library/3.6/dismo/java

---