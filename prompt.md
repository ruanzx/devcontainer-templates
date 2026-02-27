Create the markify-in-docker feature by following the instructions and the patterns used in features/markitdown-in-docker.
markify-in-docker feature will be used to convert various files format/url into markdown file format.

Tasks:
- Create the features/markify-in-docker folder with the required files:
  - install.sh: Installation script.
  - devcontainer-feature.json: Metadata and configuration options.
  - README.md: Documentation for the feature.

- Match the scripting pattern used in features/markitdown-in-docker:
  - Use utils.sh for shared utilities.
  - Use docker image ruanzx/markify
  - Implement proper logging and error handling.
  - Validate system requirements (e.g., OS, architecture).

- Test the install.sh script:
  - Verify installation works as expected.
  - Test with different versions and configurations.

- Create a sample in folder examples/markify-in-docker to let developer test the created feature, with required files:
  - .devcontainer/devcontainer.json: metadata and configuration options
  - readme.md: Documentation for how to use the feature

- Update the project root README.md:
  - Add the new feature to the list of available features.
  - Ensure the README reflects the current state of the repository.



---

There are issues in docling-in-docker when converting a pdf to markdown. I need you analysis root cause and fix.

- Cache is not effective, need to download file again and again every run container
- Error 504 Gateway Timeout for every run

```
[INFO] 2026-02-27 03:23:24,977 [RapidOCR] base.py:22: Using engine_name: onnxruntime
[INFO] 2026-02-27 03:23:24,977 [RapidOCR] main.py:53: Using /opt/app-root/src/.cache/docling/models/RapidOcr/onnx/PP-OCRv4/det/ch_PP-OCRv4_det_infer.onnx
[INFO] 2026-02-27 03:23:25,027 [RapidOCR] base.py:22: Using engine_name: onnxruntime
[INFO] 2026-02-27 03:23:25,028 [RapidOCR] main.py:53: Using /opt/app-root/src/.cache/docling/models/RapidOcr/onnx/PP-OCRv4/cls/ch_ppocr_mobile_v2.0_cls_infer.onnx
[INFO] 2026-02-27 03:23:25,049 [RapidOCR] base.py:22: Using engine_name: onnxruntime
[INFO] 2026-02-27 03:23:25,049 [RapidOCR] main.py:53: Using /opt/app-root/src/.cache/docling/models/RapidOcr/onnx/PP-OCRv4/rec/ch_PP-OCRv4_rec_infer.onnx
[INFO] 2026-02-27 03:23:37,535 [RapidOCR] download_file.py:68: Initiating download: https://www.modelscope.cn/models/RapidAI/RapidOCR/resolve/v3.4.0/resources/fonts/FZYTK.TTF
[INFO] 2026-02-27 03:23:38,947 [RapidOCR] download_file.py:82: Download size: 3.09MB
[INFO] 2026-02-27 03:23:50,835 [RapidOCR] download_file.py:95: Successfully saved to: /opt/app-root/lib/python3.12/site-packages/rapidocr/models/FZYTK.TTF
INFO:     172.17.0.1:53276 - "POST /v1/convert/file HTTP/1.1" 504 Gateway Timeout
INFO:     Shutting down
INFO:     Waiting for application shutdown.
INFO:     Application shutdown complete.
INFO:     Finished server process [1]
 *  Terminal will be reused by tasks, press any key to close it. 
```