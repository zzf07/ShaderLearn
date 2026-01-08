using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class RenderToCubemap : EditorWindow
{
    GameObject obj;
    Cubemap cubeMap;
    [MenuItem("工具/生成立方体纹理")]
    static void OpenWindow()
    {
        RenderToCubemap window =EditorWindow.GetWindow<RenderToCubemap>("生成立方体纹理");
        window.Show();
    }
    private void OnGUI()
    {
        GUILayout.Label("关联场景内物体");
        obj = EditorGUILayout.ObjectField(obj, typeof(GameObject), true) as GameObject;
        GUILayout.Label("关联立方体纹理");
        cubeMap = EditorGUILayout.ObjectField(cubeMap, typeof(Cubemap), false) as Cubemap;
        if (GUILayout.Button("生成立方体纹理"))
        {
            if (obj == null || cubeMap == null)
            {
                EditorUtility.DisplayDialog("警告", "有未关联的对象", "确认");
                return;
            }
            GameObject posObj = new GameObject("临时");
            posObj.transform.parent = obj.transform;
            obj.SetActive(false);
            Camera camera = posObj.AddComponent<Camera>();
            camera.RenderToCubemap(cubeMap);
            obj.SetActive(true);
            DestroyImmediate(camera.gameObject);
        }
    }
}
