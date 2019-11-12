using UnityEngine;

[ExecuteAlways]
public class WindControl : MonoBehaviour
{
    public Camera RTCamera;

    public ComputeShader shader;
    public RenderTexture renderTex;

    void RunShader2()
    {
        int kernelHandle = shader.FindKernel( "CSMain" );

        RenderTextureDescriptor desc = new RenderTextureDescriptor();
        desc = renderTex.descriptor;
        desc.enableRandomWrite = true;
        RenderTexture tmpSource = RenderTexture.GetTemporary( desc );
        Graphics.Blit( renderTex, tmpSource );

        shader.SetTexture( kernelHandle, "bendTexture", tmpSource);
        shader.Dispatch( kernelHandle, renderTex.width / 8, renderTex.height / 8, 1 );
        Graphics.Blit( tmpSource, renderTex );
        RenderTexture.ReleaseTemporary( tmpSource );
    }

    void RunShader()
    {
        int kernelHandle = shader.FindKernel("CSMain");

        RenderTexture tex = new RenderTexture( 256, 256, 0 );
        tex.enableRandomWrite = true;
        tex.Create();

        shader.SetTexture(kernelHandle, "bendTexture", tex);
        shader.Dispatch(kernelHandle, 256 / 8, 256 / 8, 1);
        Graphics.Blit(tex, renderTex );
    }

    void Update()
    {
        if (RTCamera != null)
        {
            RunShader2();
            Shader.SetGlobalVector("G_RTCameraPosition", RTCamera.transform.position);
            Shader.SetGlobalFloat("G_RTCameraSize", RTCamera.orthographicSize);
        }
    }
}
