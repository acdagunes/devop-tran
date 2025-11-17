# ვიყენებთ Nginx-ის ოფიციალურ იმიჯს
FROM nginx:latest

# სტანდარტული Nginx-ის პორტია 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
