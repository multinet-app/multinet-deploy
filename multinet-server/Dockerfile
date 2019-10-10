FROM python:3.7-buster
WORKDIR /code
ENV FLASK_APP app.py
ENV FLASK_RUN_HOST 0.0.0.0
RUN pip install pipenv
RUN git clone https://github.com/multinet-app/multinet.git
RUN cd multinet && pipenv install 
CMD cd multinet && pipenv run serve