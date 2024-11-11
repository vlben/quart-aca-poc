FROM python:3.12.7-alpine

WORKDIR /app

COPY ./ /app

RUN python -m pip install -r requirements.txt

RUN python -m pip install gunicorn

EXPOSE 8000

CMD ["gunicorn", "-w", "1", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]
