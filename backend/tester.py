import torch
from torchvision import models

# Initialize your model (assuming EfficientNet, adjust accordingly)
model = models.efficientnet_b0(pretrained=False)  # Set pretrained=False since you'll be loading your custom weights

# Load the model weights
MODEL_PATH = "C:/Users/virus/OneDrive/Desktop/Banana Thesis/efficientnetv2_banana_classification.pth"  # Replace with your model's path
try:
    model.load_state_dict(torch.load(MODEL_PATH, weights_only=True), strict=False)
  # Load weights with strict=False to avoid errors due to missing/extra keys
    print("Model weights loaded successfully.")
except Exception as e:
    print(f"Error loading the model: {e}")

# Now the model is ready to be used
model.eval()  # Set the model to evaluation mode if you're doing inference

# Example inference
# image_tensor = some_image_preprocessed_to_tensor  # Your input image tensor
# output = model(image_tensor)
