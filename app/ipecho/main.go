package main

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/netip"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	var (
		sig         = make(chan os.Signal)
		ctx, cancel = context.WithCancel(context.Background())
	)

	logDebug("main.running")

	signal.Notify(sig, syscall.SIGHUP, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sig
		cancel()
	}()

	if err := server(ctx); err != nil {
		logDebug("main.server.nested: %s", err.Error())
	} else {
		logDebug("main.server.run")
	}

	<-ctx.Done()
	logDebug("main.exiting")
	time.Sleep(time.Second)
}

func server(ctx context.Context) error {
	ln, err := net.Listen("tcp", fmt.Sprintf(":%d", config.Port))
	if err != nil {
		logErr("server.net.Listen (port:%d): %s", config.Port, err.Error())
		return err
	}

	go func() {
		<-ctx.Done()
		if err1 := ln.Close(); err1 != nil {
			logErr("server.Close: %s", err.Error())
		}
	}()

	go netListener(ln)

	return nil
}

func netListener(listener net.Listener) {
	var (
		err  error
		conn net.Conn
	)

	for {
		if conn, err = listener.Accept(); err != nil {
			if !errors.Is(err, net.ErrClosed) {
				logErr("netListener.listener.Accept: %s", err.Error())
			}

			return
		}

		handle(conn)
	}
}

var resp = []byte(`HTTP/1.1 200 ok
Cache-Control: max-age=1,private
Cache-Control: no-cache, no-store, must-revalidate
Content-Type: text/plain; charset=UTF-8

`)

func handle(conn net.Conn) {
	defer func() {
		if err := conn.Close(); err != nil {
			logErr("handle.conn.Close: %s", err.Error())
		}
	}()

	addrPort, err := netip.ParseAddrPort(conn.RemoteAddr().String())
	if err != nil {
		logErr("handle.netip.ParseAddrPort (addr: %s) : %s", conn.RemoteAddr().String(), err.Error())
		return
	}

	if _, err = conn.Write(addrPort.Addr().AppendTo(resp)); err != nil {
		logErr("handle.conn.Write: %s", err.Error())
	}
}
