using UnityEngine;

[ExecuteAlways]
public class WindControl : MonoBehaviour
{
    public Camera RTCamera;

    void Update()
    {
        if (RTCamera != null)
        {
            Shader.SetGlobalVector("G_RTCameraPosition", RTCamera.transform.position);
            Shader.SetGlobalFloat("G_RTCameraSize", RTCamera.orthographicSize);
        }
    }
}
