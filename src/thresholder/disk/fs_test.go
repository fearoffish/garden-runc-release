package disk_test

import (
	"fmt"
	"os/exec"
	"regexp"
	"strconv"
	"thresholder/disk"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("SysFS", func() {
	It("uses statfs(2) to get the FS stats", func() {
		fs := disk.NewSysFS()
		stat, err := fs.Stat("/")

		Expect(err).NotTo(HaveOccurred())
		Expect(stat.AvailableBlocks).To(Equal(dfAvailBlocks("/", stat.BlockSize)))
	})
})

func dfAvailBlocks(path string, blockSize int64) int64 {
	cmd := exec.Command("df", path, "--output=avail", fmt.Sprintf("--block-size=%d", blockSize))
	output, err := cmd.Output()
	Expect(err).NotTo(HaveOccurred())

	blocksStr := regexp.MustCompile(`\d+`).FindString(string(output))
	blocks, err := strconv.ParseInt(blocksStr, 10, 64)
	Expect(err).NotTo(HaveOccurred())

	return blocks
}
