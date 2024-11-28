from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from torchvision.models import efficientnet_v2_s
from torchvision import transforms
from PIL import Image
import torch
import torch.nn as nn

# Initialize FastAPI app
app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can replace "*" with specific origins, e.g. ["http://localhost:55745"]
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods
    allow_headers=["*"],  # Allows all headers
)

# Model loading function (singleton pattern)
def load_model(num_classes=8):
    if not hasattr(load_model, "_model"):
        print("Loading model...")
        model = efficientnet_v2_s(pretrained=False)
        model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)
        MODEL_PATH = "C:/Users/virus/OneDrive/Desktop/Banana Thesis/efficientnetv2_banana_classification.pth"
        state_dict = torch.load(MODEL_PATH, map_location=torch.device('cpu'), weights_only=True)
        model.load_state_dict(state_dict)
        model.eval()
        load_model._model = model
    return load_model._model

# Image preprocessing
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

class_names = [
    "lakatan_ripe_spotted", "lakatan_ripe_unspotted",
    "lakatan_unripe_spotted", "lakatan_unripe_unspotted",
    "latundan_ripe_spotted", "latundan_ripe_unspotted",
    "latundan_unripe_spotted", "latundan_unripe_unspotted"
]

@app.get("/")
def read_root():
    return {"message": "Welcome to the Banana Classification API!"}

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    # Load the model (only once, thread-safe)
    model = load_model()

    # Load the image
    image = Image.open(file.file).convert("RGB")

    # Preprocess the image
    input_tensor = transform(image).unsqueeze(0)

    # Perform prediction
    with torch.no_grad():
        outputs = model(input_tensor)
        _, predicted = torch.max(outputs, 1)
        prediction = class_names[predicted.item()]

    return {"class": prediction}
