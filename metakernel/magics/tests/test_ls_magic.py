
import os
from metakernel.tests.utils import (get_kernel, get_log_text,
                                    clear_log_text)


def test_ls_magic():
    kernel = get_kernel()
    kernel.do_execute("%ls")
    text = get_log_text(kernel)
    assert "Display Data" in text, text
    clear_log_text(kernel)

    kernel.do_execute("%ls -d")
    text = get_log_text(kernel)
    assert "Display Data" in text, text
    clear_log_text(kernel)