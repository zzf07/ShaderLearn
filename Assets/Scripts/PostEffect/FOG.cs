using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("ÆÁÄ»ºó´¦Àí/FOG")]
public class FOG : PostEffectBase
{
    //public float fogStart;
    //public float fogEnd;
    public Color fogColor;
    [Range(0f, 1f)]
    public float fogDensity;
    private void Start()
    {
        shader = Shader.Find("Unlit/FOG");
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        float near = Camera.main.nearClipPlane;
        float halfH = near * Mathf.Tan(Camera.main.fieldOfView / 2);
        float halfW = halfH * Camera.main.aspect;
        Vector3 toTop = Camera.main.transform.up * halfH;
        Vector3 toRight = Camera.main.transform.right * halfW;
        Vector3 TL = Camera.main.transform.forward * near + toTop - toRight;
        Vector3 TR = Camera.main.transform.forward * near + toTop + toRight;
        Vector3 BL = Camera.main.transform.forward * near - toTop - toRight;
        Vector3 BR = Camera.main.transform.forward * near - toTop + toRight;
        float Scale = TL.magnitude/ near;
        Vector3 RayTL = TL.normalized * Scale;
        Vector3 RayTR = TR.normalized * Scale;
        Vector3 RayBL = BL.normalized * Scale;
        Vector3 RayBR = BR.normalized * Scale;
        material.SetVector("_RayTL", RayTL);
        material.SetVector("_RayTR", RayTR);
        material.SetVector("_RayBL", RayBL);
        material.SetVector("_RayBR", RayBR);
        //material.SetFloat("_FOGStart", fogStart);
        //material.SetFloat("_FOGEnd",fogEnd);
        material.SetColor("_FOGColor", fogColor);
        material.SetFloat("_FOGDensity", fogDensity);
        Graphics.Blit(source, destination, material);
    }
}
