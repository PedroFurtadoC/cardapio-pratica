import motor.motor_asyncio
from dotenv import load_dotenv
import os

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
MONGO_DB = os.getenv("MONGO_DB")

client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_URI)
db = client[MONGO_DB]

usuarios_collection = db.get_collection("usuarios")
produtos_collection = db.get_collection("produtos")
componentes_collection = db.get_collection("componentes")
pedidos_collection = db.get_collection("pedidos")
