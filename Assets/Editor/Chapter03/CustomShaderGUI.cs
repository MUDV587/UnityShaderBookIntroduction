using System;
using UnityEngine;
using UnityEditor;

public class CustomShaderGUI : ShaderGUI
{
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // render the default GUI
        base.OnGUI(materialEditor, properties);

        Material targetMaterial = materialEditor.target as Material;

        // see if redify is set, and show a checbox
        bool redify = Array.IndexOf(targetMaterial.shaderKeywords, "REDIFY_ON") != -1;
        EditorGUI.BeginChangeCheck();
        redify = EditorGUILayout.Toggle("Redify Materical", redify);
        if (EditorGUI.EndChangeCheck())
        {
            // enable or disable the keyword based on checkbox
            if (redify)
            {
                targetMaterial.EnableKeyword("REDIFY_ON");
            }
            else
            {
                targetMaterial.DisableKeyword("REDIFY_ON");
            }
        }
    }
}
