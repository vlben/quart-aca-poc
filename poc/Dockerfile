FROM python:3.12.7-slim-bullseye

WORKDIR /poc

COPY ./ /poc

RUN python -m pip install --no-cache-dir -r requirements.txt

RUN python -m pip install gunicorn

EXPOSE 8000

CMD ["gunicorn", "-w", "1", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]
