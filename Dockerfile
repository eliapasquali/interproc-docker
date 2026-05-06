FROM ocaml/opam:alpine-ocaml-4.13-flambda AS build
LABEL author="Davide Albiero, Damiano Mason"

WORKDIR /home/opam

# PPL related
# Update system 
RUN sudo apk add m4 gmp-dev gmp-static perl mpfr-dev --no-cache
# Dwwnload PPL archive, build and install it, then remove those files 
RUN wget https://support.bugseng.com/ppl/download/ftp/releases/1.2/ppl-1.2.tar.xz && \
    tar xfv ppl-1.2.tar.xz && \
    cd ppl-1.2 && \
    ./configure && \
    make -j$(nproc) && \
    sudo make install && \
    # could skip install check to save time
    make -j$(nproc) installcheck && \
    cd .. && \
    rm -rf ppl-1.2 ppl-1.2.tar.xz 

# OPAM related
# Install needed (online) libraries 
RUN opam install conf-ppl apron -y
# Move fixed version libraries to the container
# fix permissions during copy 
COPY --chown=opam:opam src/camllib /home/opam/camllib
COPY --chown=opam:opam src/fixpoint /home/opam/fixpoint
COPY --chown=opam:opam src/interproc /home/opam/interproc
# Pin those version with -n to avoid install at every pin
RUN opam pin add camllib ./camllib -n && \
    opam pin add fixpoint ./fixpoint -n && \ 
    opam pin add interproc ./interproc -n && \
    # depext takes care of install pinned libs
    opam depext -i interproc -y && \
    opam exec -- make -C /home/opam/interproc all

FROM httpd:2.4-alpine AS server
LABEL author="Davide Albiero, Damiano Mason"

WORKDIR /usr/local/apache2

COPY --from=build /home/opam/interproc/_build/default/interprocweb.exe /usr/local/apache2/cgi-bin/interproc 
COPY src/interproc/examples/* /usr/local/apache2/cgi-bin/examples/ 
COPY frontend/show_program.js /usr/local/apache2/htdocs/show_program.js 
COPY frontend/index.html /usr/local/apache2/htdocs/interproc.html 
COPY docker/httpd.conf /usr/local/apache2/conf/httpd.conf

CMD ["httpd-foreground"]

EXPOSE 80
