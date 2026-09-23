# Zabtrain — тренажёр триггерных выражений Zabbix

Flask-приложение для тренировки и отработки навыков написания триггерных выражений Zabbix.

## Запуск через Docker

```bash
# Сборка образа
docker build -t zabtrain:latest .

# Запуск (порт 5000)
docker run -d --name zabtrain -p 5000:5000 zabtrain:latest

# Проверка
curl http://localhost:5000/

# Остановка
docker stop zabtrain && docker rm zabtrain
```

## Запуск локально

```bash
pip install -r requirements.txt
python app.py
```

## Запуск через shell
```bash
chmod +x Zabtrain.sh
./Zabtrain.sh
```
