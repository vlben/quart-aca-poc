from quart import Quart


async def setup_app(current_app: Quart):
    current_app.is_setup = True
    print("Setup app succesfully.")

    return current_app
