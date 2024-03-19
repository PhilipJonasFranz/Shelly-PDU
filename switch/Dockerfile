FROM node 
WORKDIR /app
COPY package.json . 
RUN npm i
COPY . . 
EXPOSE 80
CMD ["node", "index.js"] 