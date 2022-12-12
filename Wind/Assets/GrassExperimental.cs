using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
[RequireComponent(typeof(WindZone))]
public class GrassExperimental : MonoBehaviour
{
    public bool enableDecalAO = false;

    private Texture2D m_WindBaseTex;
    private Shader m_WindCompositeShader;

    public float m_Grass = 1.0f;
    public float m_Foliage = 1.0f;

    public float m_Size = 0.01f;
    public float m_Speed = 0.05f;
    public float m_SpeedLayer0 = 0.476f;
    public float m_SpeedLayer1 = 1.23f;
    public float m_SpeedLayer2 = 2.93f;

    public int m_GrassGustTiling = 4;
    public float m_GrassGustSpeed = 0.278f;

    public float m_JitterFrequency = 3.127f;
    public float m_JitterHighFrequency = 21.0f;

    public RenderTexture m_WindRT;
    public Material m_Material;

    public Vector2 uvs = new Vector2(0, 0);
    public Vector2 uvs1 = new Vector2(0, 0);
    public Vector2 uvs2 = new Vector2(0, 0);
    public Vector2 uvs3 = new Vector2(0, 0);

    public Transform m_Trans;
    public WindZone m_WindZone;
    public float m_MainWind;
    public float m_Turbulence;

    public int _WindDirSize;
    public int _WindStrengthMultipliers;
    public int _SinTime;
    public int _Gust;

    public int _WindUVs;
    public int _WindUVs1;
    public int _WindUVs2;
    public int _WindUVs3;

    public Vector4 m_WindDirectionSize = Vector4.zero;

    public bool m_IsValid;

    private void OnEnable()
    {
        if (m_WindBaseTex == null)
            m_WindBaseTex = Resources.Load("Default wind base texture") as Texture2D;

        if (m_WindCompositeShader == null)
            m_WindCompositeShader = Shader.Find("Hidden/GrassExperimental/WindComposite");

        if(m_WindBaseTex == null || m_WindCompositeShader == null)
        {
            m_IsValid = false;
            return;
        }
        else
        {
            m_IsValid = true;
        }

        if(m_WindRT == null)
        {
            m_WindRT = new RenderTexture(512, 512, 0, RenderTextureFormat.ARGBHalf, RenderTextureReadWrite.Linear);
            m_WindRT.useMipMap = true;
            m_WindRT.wrapMode = TextureWrapMode.Repeat;
        }

        if(m_Material == null)
        {
            m_Material = new Material(m_WindCompositeShader);
        }

        _WindDirSize = Shader.PropertyToID("_WindDirSize");
        _WindStrengthMultipliers = Shader.PropertyToID("_WindStrengthMultipliers");
        _SinTime = Shader.PropertyToID("_WindSinTime");
        _Gust = Shader.PropertyToID("_Gust");
        _WindUVs = Shader.PropertyToID("_WindUVs");
        _WindUVs1 = Shader.PropertyToID("_WindUVs1");
        _WindUVs2 = Shader.PropertyToID("_WindUVs2");
        _WindUVs3 = Shader.PropertyToID("_WindUVs3");

        m_Trans = this.transform;
        m_WindZone = m_Trans.GetComponent<WindZone>();

    }

    private void OnValidate()
    {
        if (m_WindBaseTex == null)
            m_WindBaseTex = Resources.Load("Default wind base texture") as Texture2D;

        if (m_WindCompositeShader == null)
            m_WindCompositeShader = Shader.Find("Hidden/GrassExperimental/WindComposite");

        if (m_WindBaseTex == null || m_WindCompositeShader == null)
        {
            m_IsValid = false;
            return;
        }
        else
        {
            m_IsValid = true;
        }
    }

    private void LateUpdate()
    {
        if (!m_IsValid)
            return;

        if (enableDecalAO)
            Shader.SetGlobalFloat("_DecalAOEnable", 1.0f);
        else
            Shader.SetGlobalFloat("_DecalAOEnable", 0.0f);

        m_MainWind = m_WindZone.windMain;
        m_Turbulence = m_WindZone.windTurbulence;

        float delta = Time.deltaTime;
        m_WindDirectionSize.x = m_Trans.forward.x;
        m_WindDirectionSize.y = m_Trans.forward.y;
        m_WindDirectionSize.z = m_Trans.forward.z;
        m_WindDirectionSize.w = m_Size;

        var windVec = new Vector2(m_WindDirectionSize.x, m_WindDirectionSize.z) * delta * m_Speed;

     

        uvs -= windVec * m_SpeedLayer0 ;
        uvs.x = uvs.x - (int)uvs.x;
        uvs.y = uvs.y - (int)uvs.y;

        uvs1 -= windVec * m_SpeedLayer1 ;
        uvs1.x = uvs1.x - (int)uvs1.x;
        uvs1.y = uvs1.y - (int)uvs1.y;

        uvs2 -= windVec * m_SpeedLayer2;
        uvs2.x = uvs2.x - (int)uvs2.x;
        uvs2.y = uvs2.y - (int)uvs2.y;

        uvs3 -= windVec * m_GrassGustSpeed;
        uvs3.x = uvs3.x - (int)uvs3.x;
        uvs3.y = uvs3.y - (int)uvs3.y;

        //	Set global shader variables for grass and foliage shaders
        Shader.SetGlobalVector(_WindDirSize, m_WindDirectionSize);
        Vector2 tempWindstrengths;
        tempWindstrengths.x = m_Grass * m_MainWind;
        tempWindstrengths.y = m_Foliage * m_MainWind;
        Shader.SetGlobalVector(_WindStrengthMultipliers, tempWindstrengths);
        Shader.SetGlobalVector(_Gust, new Vector2(m_GrassGustTiling, m_Turbulence + 0.5f));
        //	Jitter frequncies and strength
        Shader.SetGlobalVector(_SinTime, new Vector4(
            Mathf.Sin(Time.time * m_JitterFrequency),
            Mathf.Sin(Time.time * m_JitterFrequency * 0.2317f + 2.0f * Mathf.PI),
            Mathf.Sin(Time.time * m_JitterHighFrequency),
            m_Turbulence * 0.1f
        ));

        //	Set UVs
        Shader.SetGlobalVector(_WindUVs, uvs);
        Shader.SetGlobalVector(_WindUVs1, uvs1);
        Shader.SetGlobalVector(_WindUVs2, uvs2);
        Shader.SetGlobalVector(_WindUVs3, uvs3);

        Graphics.Blit(m_WindBaseTex, m_WindRT, m_Material);
        m_WindRT.SetGlobalShaderProperty("_WindRT");
    }
}
