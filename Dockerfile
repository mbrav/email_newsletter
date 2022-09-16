FROM rust:1.63 as builder

WORKDIR /app
COPY . .

ENV SQLX_OFFLINE true
RUN apt update && \
    apt install -y lld clang && \
    cargo build --release


FROM debian:11-slim

RUN apt update && \
    apt install -y --no-install-recommends openssl ca-certificates && \
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/email_newsletter /
COPY conf.yaml /

ENTRYPOINT ["./email_newsletter"]