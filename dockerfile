FROM ocaml/opam:alpine as build

RUN sudo apk add ocaml-runtime

COPY ./server.bc /bin/server

ENTRYPOINT ocamlrun /bin/server
