from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from torchvision.models import efficientnet_v2_s
from torchvision import transforms
from PIL import Image
import torch
import torch.nn as nn
from rembg import remove
import io

# Initialize FastAPI app
app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=".*",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load EfficientNetV2S model with 4 output classes
def load_model(num_classes=4):
    if not hasattr(load_model, "_model"):
        print("Loading model...")
        model = efficientnet_v2_s(pretrained=False)
        model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)
        MODEL_PATH = "C:/Users/virus/OneDrive/Desktop/Banana Thesis/efficientnet_banana_classification.pth"
        state_dict = torch.load(MODEL_PATH, map_location=torch.device('cpu'))
        model.load_state_dict(state_dict)
        model.eval()
        load_model._model = model
    return load_model._model

# Preprocessing transform
transform = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# 4 output classes
class_names = [
    "lakatan_ripe",
    "lakatan_unripe",
    "latundan_ripe",
    "latundan_unripe"
]

@app.get("/")
def read_root():
    return {"message": "Welcome to the Banana Classification API!"}

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    # Load model
    model = load_model()

    # Read image bytes
    image_bytes = await file.read()

    # Remove background
    no_bg_bytes = remove(image_bytes)

    # Convert bytes to PIL image
    image = Image.open(io.BytesIO(no_bg_bytes)).convert("RGB")

    # Resize to 224x224
    image = image.resize((224, 224))

    # Transform
    input_tensor = transform(image).unsqueeze(0)

    # Predict
    with torch.no_grad():
        outputs = model(input_tensor)
        probabilities = torch.softmax(outputs, dim=1)
        confidence, predicted = torch.max(probabilities, 1)
        predicted_class = class_names[predicted.item()]

    return {
        "class": predicted_class,
        "confidence": round(confidence.item() * 100, 2)
    }
