FROM ocaml/opam:alpine as build

# Install system dependencies
RUN sudo apk add --update libev-dev openssl-dev nodejs npm

WORKDIR /home/opam

# Install Opam dependencies
RUN opam install dune --yes
RUN opam install dream --yes
RUN opam install ppx_yojson_conv --yes
RUN opam install ppx_let --yes
RUN opam install . --deps-only

# Build project
ADD bin/ dune-project ./
RUN opam exec -- dune build

FROM alpine:3.19 as run

RUN apk add --update libev

COPY --from=build /home/opam/_build/default/server.exe /bin/server

ENTRYPOINT /bin/server
