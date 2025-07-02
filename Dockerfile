FROM php:8.2-cli

# System dependencies
RUN apt-get update && apt-get install -y \
    zip unzip curl git libpng-dev libjpeg-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application source
COPY . /var/www

# Copy default .env if not present
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Generate app key
RUN php artisan key:generate || true

# Set correct permissions for Laravel
RUN chmod -R 777 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Laravel serve command
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=9000"]
