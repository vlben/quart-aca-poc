import os

from api.setup_api import setup_app
from quart import (Blueprint, Quart, jsonify, current_app)
from dotenv import load_dotenv

load_dotenv()
bp = Blueprint("routes", __name__, static_folder="static")


@bp.route('/')
async def home():
    return "Welcome to the Quart app!"


@bp.route('/hello', methods=['GET'])
async def hello():
    return jsonify({"message": "Hello, World!"})


@bp.route('/env', methods=['GET'])
async def env():
    return jsonify({"message": os.getenv("TEST_VAR")})


@bp.before_app_serving
async def setup_clients():
    await setup_app(current_app)


@bp.after_app_serving
async def close_clients():
    if hasattr(current_app, "is_setup"):
        print("Closing app...")


def create_app():
    app = Quart(__name__)
    app.register_blueprint(bp)

    return app
