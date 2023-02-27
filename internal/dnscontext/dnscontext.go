package dnscontext

import (
	"io/ioutil"
	"os"
	"strings"
)

// resolveConfig provides API for editing / reading resolv.conf
type resolveConfig struct {
	path       string
	properties map[string][]string
}

// openResolveConfig reads resolve config file from specific path
func OpenResolveConfig(p string) (*resolveConfig, error) {
	r := &resolveConfig{
		path:       p,
		properties: make(map[string][]string),
	}
	if err := r.readProperties(); err != nil {
		return nil, err
	}
	return r, nil
}

func (r *resolveConfig) readProperties() error {
	b, err := ioutil.ReadFile(r.path)
	if err != nil {
		return err
	}
	for _, l := range strings.Split(string(b), "\n") {
		words := strings.Split(l, " ")
		if len(words) > 1 {
			r.properties[words[0]] = words[1:]
		}
	}
	return nil
}

// Value returns value of property
func (r *resolveConfig) Value(k string) []string {
	return r.properties[k]
}

// SetValue sets value for specific property
func (r *resolveConfig) SetValue(k string, values ...string) {
	if len(values) == 0 {
		delete(r.properties, k)
	} else {
		r.properties[k] = values
	}
}

// Save saves resolve config file
func (r *resolveConfig) Save() error {
	var sb strings.Builder
	var index int
	for k, v := range r.properties {
		_, _ = sb.WriteString(strings.Join(append([]string{k}, v...), " "))
		index++
		if index < len(r.properties) {
			_, _ = sb.WriteRune('\n')
		}
	}
	return ioutil.WriteFile(r.path, []byte(sb.String()), os.ModePerm)
}

const (
	// searchProperty means search list for host-name lookup
	SearchProperty = "search"
	// nameserverProperty means name server IP address
	NameserverProperty = "nameserver"
	// optionsProperty  allows certain internal resolver variables to be modified
	OptionsProperty = "options"
)
