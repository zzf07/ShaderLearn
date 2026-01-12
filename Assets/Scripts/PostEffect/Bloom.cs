using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
{
    [Range(0,1.5f)]
    public float LThreshold;
    public Color bloomColor;
    [Range(1.0f, 8.0f)]
    public int downSample;
    [Range(0f, 8.0f)]
    public int iteration;
    [Range(0, 3)]
    public float blurSpread;
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        material.SetFloat("_LThreshold", LThreshold);
        material.SetColor("_BloomColor",bloomColor);
        int w = source.width/downSample;
        int h = source.height/downSample;

        RenderTexture buffer0 = RenderTexture.GetTemporary(w, h, 0);
        buffer0.filterMode = FilterMode.Bilinear;
        Graphics.Blit(source,buffer0,material, 0);

        for(int i = 0; i < iteration; i++)
        {
            material.SetFloat("_BlurSpread",1+i*blurSpread);
            RenderTexture buffer1 = RenderTexture.GetTemporary(w, h, 0);
            Graphics.Blit (buffer0,buffer1,material, 1);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = RenderTexture.GetTemporary(w, h,0);

            Graphics.Blit(buffer1,buffer0,material, 2);
            RenderTexture.ReleaseTemporary(buffer1);
        }
        material.SetTexture("_Bloom",buffer0 );
        Graphics.Blit(source,destination, material, 3);
        RenderTexture.ReleaseTemporary(buffer0);
    }
}
