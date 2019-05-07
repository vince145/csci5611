public class Vector2D {
  float x;
  float z;
  
  Vector2D(float newX, float newZ) {
    x = newX;
    z = newZ;
  }
  
  void scaler(float scalerValue) {
    x = x * scalerValue;
    z = z * scalerValue;
  }
  
  Vector2D scalerNC(float scalerValue) {
    Vector2D resultVector = new Vector2D(x*scalerValue, z*scalerValue);
    return resultVector;
  }
  
  void addV(Vector2D addVector) {
    x = x + addVector.x;
    z = z + addVector.z;
  }
  
  void divide(float divideValue) {
    if (divideValue != 0) {
      x = (float) x / (float) divideValue;
      z = (float) z / (float) divideValue;
    }
  }
  
  Vector2D divideNC(float scalerValue) {
    if (scalerValue != 0) {
      float newX = ((float) x)/ (float) scalerValue;
      float newZ = ((float) z)/ (float) scalerValue;
      Vector2D resultVector = new Vector2D(newX, newZ);
      return resultVector;
    } else {
      Vector2D resultVector = new Vector2D(x, z);
      return resultVector;
    }
  }
  
  float magnitude() {
    return sqrt((float) (((x*x)+(z*z))));
  }
  
  void normalizeV() {
    float mag = sqrt((float) (x*x)+(z*z));
    if (mag != 0) {
      x = x/(mag);
      z = z/(mag);
    }
  }
  
  // Calculates distance from point startV to .this point.
  Vector2D d(Vector2D startV) {
    Vector2D distanceVector = new Vector2D(x-startV.x, z-startV.z);
    return distanceVector;
  }
  
  float dotProd(Vector2D startV) {
    float dotProduct = (x * startV.x) + (z * startV.z);
    return dotProduct;
  }
  
  void reset() {
    x = 0;
    z = 0;
  }
}

public class Vector3D {
  float x;
  float y;
  float z;
  
  Vector3D(float newX, float newY, float newZ) {
    x = newX;
    y = newY;
    z = newZ;
  }
  
  void scaler(float scalerValue) {
    x = x * scalerValue;
    y = y * scalerValue;
  }
  
  Vector3D scalerNC(float scalerValue) {
    Vector3D resultVector = new Vector3D(x*scalerValue, y*scalerValue, z*scalerValue);
    return resultVector;
  }
  
  void addV(Vector3D addVector) {
    x = x + addVector.x;
    y = y + addVector.y;
  }
  
  void divide(float divideValue) {
    if (divideValue != 0) {
      x = (float) x / (float) divideValue;
      y = (float) y / (float) divideValue;
      z = (float) z / (float) divideValue;
    }
  }
  
  Vector3D divideNC(float scalerValue) {
    if (scalerValue != 0) {
      float newX = ((float) x)/ (float) scalerValue;
      float newY = ((float) y)/ (float) scalerValue;
      float newZ = ((float) z)/ (float) scalerValue;
      Vector3D resultVector = new Vector3D(newX, newY, newZ);
      return resultVector;
    } else {
      Vector3D resultVector = new Vector3D(x, y, z);
      return resultVector;
    }
  }
  
  float magnitude() {
    return sqrt((float) (((x*x)+(y*y)+(z*z))));
  }
  
  void normalizeV() {
    float mag = sqrt((float) (x*x)+(y*y)+(z*z));
    if (mag != 0) {
      x = x/(mag);
      y = y/(mag);
    }
  }
  
  // Calculates distance from point startV to .this point.
  Vector3D d(Vector3D startV) {
    Vector3D distanceVector = new Vector3D(x-startV.x, y-startV.y, z-startV.z);
    return distanceVector;
  }
  
  float dotProd(Vector3D startV) {
    float dotProduct = (x * startV.x) + (y * startV.y) + (z * startV.z);
    return dotProduct;
  }
  
  void reset() {
    x = 0;
    y = 0;
  }
}
