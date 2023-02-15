FROM node:18.14.0 as client-builder

COPY . .
WORKDIR /
RUN cd types && yarn
RUN cd ../client && yarn && yarn build

FROM node:18.14.0 as server-builder

COPY . .
WORKDIR /
RUN cd types && yarn
RUN cd ../ &&yarn && yarn heroku-postbuild

FROM node:18.14.0 as dependency-builder

COPY package.json /
ENV NODE_ENV=production
WORKDIR /
RUN yarn

FROM node:18.14.0 as node

WORKDIR /

COPY --from=server-builder /server/lib /server/lib
COPY --from=client-builder /client/dist /dist
COPY --from=dependency-builder /node_modules /node_modules

CMD ["node", "/server/lib/server/index.js"]
