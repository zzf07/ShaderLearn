using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicView : MonoBehaviour
{
    public AudioSource audioSource;
    public int spectrumSize = 1024;
    public FFTWindow window = FFTWindow.Blackman;
    float[] spectrumData;
    float[] frequencyBands = new float[8];
    int[] bandLimits = new int[9] { 20, 60, 150, 250, 500, 1000, 2000, 4000, 20000 };
    float[] smoothedBands = new float[8];
    public float smoothSpeed = 10f;
    public float[] normalizedBands = new float[8];
    public float min = 0;
    public float max = 0.1f;
    public Material material;
    // Start is called before the first frame update
    void Start()
    {
        audioSource = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        if (audioSource == null) return;
        CalculateFrequencyBands();
        SmoothBands();
        NormalizedZero2One();

        if (material != null)
        {
            smoothedBands[7] -= 0.01f;
            material.SetFloatArray("_Audio", smoothedBands);
        }
    }
    void CalculateFrequencyBands()
    {
        spectrumData = new float[spectrumSize];
        audioSource.GetSpectrumData(spectrumData, 0, window);
        System.Array.Clear(frequencyBands, 0, frequencyBands.Length);
        // 3. 将频谱数据映射到8个频段
        int sampleRate = AudioSettings.outputSampleRate;
        float freqPerBin = sampleRate / 2f / spectrumSize;

        for (int i = 0; i < spectrumSize; i++)
        {
            float frequency = i * freqPerBin;

            // 确定当前频率属于哪个频段
            for (int band = 0; band < 8; band++)
            {
                if (frequency >= bandLimits[band] && frequency < bandLimits[band + 1])
                {
                    // 累加该频段的能量
                    frequencyBands[band] += spectrumData[i];
                    break;
                }
            }
            //for(int band = 0;band < 8; band++)
            //{
            //    frequencyBands[band] /= 8;
            //}
        }
    }
    void SmoothBands()
    {
        for (int i = 0; i < 8; i++)
        {
            smoothedBands[i] = Mathf.Lerp(smoothedBands[i],frequencyBands[i],Time.deltaTime * smoothSpeed);
        }
    }
    void NormalizedZero2One()
    {
        for (int i = 0; i < 8; i++)
        {
            // 将 smoothedBands 映射到 0~1 区间（基于设置的 min 和 max）
            normalizedBands[i] = Mathf.InverseLerp(min, max, smoothedBands[i]);
            // 限制最大值为1，避免超出范围
            normalizedBands[i] = Mathf.Clamp01(normalizedBands[i]);
        }
    }
}
