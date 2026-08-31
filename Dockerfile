FROM nginx:alpine

# Copy built Flutter web bundle to Nginx html directory
COPY build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
