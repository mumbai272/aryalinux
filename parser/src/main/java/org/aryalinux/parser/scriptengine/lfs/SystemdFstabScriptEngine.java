package org.aryalinux.parser.scriptengine.lfs;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.List;

import org.aryalinux.parser.commons.lfs.ScriptEngine;
import org.aryalinux.parser.commons.lfs.Step;
import org.aryalinux.parser.lfs.LFSParser;

public class SystemdFstabScriptEngine extends ScriptEngine {

	@Override
	public void generateScript(List<Step> steps, String outputDirectory)
			throws Exception {
		InputStream inputStream = getClass().getClassLoader()
				.getResourceAsStream("systemd-fstab-script-template");
		byte[] data = new byte[inputStream.available()];
		inputStream.read(data);
		inputStream.close();
		FileOutputStream fileOutputStream = new FileOutputStream(new File(
				outputDirectory + File.separator
						+ (LFSParser.mainScriptIndex++) + ".sh"));
		fileOutputStream.write(data);
		fileOutputStream.close();
	}

}
